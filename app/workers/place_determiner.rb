class PlaceDeterminer
  MAX_RETRIES = 5
  RETRY_DELAY_IN_SECONDS = 60
  @queue = :default

  def self.perform(entry_id)
    begin
      retries ||= 0
      entry = Entry.find(entry_id)

      if entry.abstract.present?
        locations = OpenCalais::ClientWrapper.new(entry.abstract).locations

        locations.each do |location|
          if location[:latitude] && location[:longitude] #NOTE: OpenCalais sometimes sends locations without latitudes and longitudes.
            place = Place.find_by_open_calais_guid(location[:guid])
            unless place
              place = Place.create(
                name: location[:name],
                open_calais_guid: location[:guid],
                latitude: location[:latitude],
                longitude: location[:longitude],
                place_type: location[:type],
              )
            end

            unless PlaceDetermination.find(
              :first,
              :conditions => {:entry_id => entry.id, :place_id => place.id}
            )
              PlaceDetermination.create(
                entry_id: entry.id,
                place_id: place.id,
                string: location[:name],
                relevance_score: location[:score]
              )
            end
          end
        end

      entry.places_determined_at = Time.now
      entry.save
    end

    rescue StandardError => e
      if e.class == Faraday::ParsingError
        sleep RETRY_DELAY_IN_SECONDS
        retry if (retries += 1) < MAX_RETRIES
        puts e.message
        puts e.backtrace.join("\n")
      end

      Honeybadger.notify(e)
    end
  end

end
