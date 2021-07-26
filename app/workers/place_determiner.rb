class PlaceDeterminer
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :place_determiner, :retry => 0

  MAX_RETRIES             = 5
  RETRY_DELAY_IN_SECONDS  = 5
  CHARACTER_REQUEST_LIMIT = 95000

  def perform(entry_id)
    ActiveRecord::Base.clear_active_connections!
    @entry = Entry.find(entry_id)

    begin
      retries ||= 0

      if entry.raw_text.present?
        locations.each do |location|
          place = Place.find_by_open_calais_guid(location[:guid])

          unless place
            place = Place.create(
              name:             location[:name],
              open_calais_guid: location[:guid],
              latitude:         location[:latitude],
              longitude:        location[:longitude],
              place_type:       location[:type]
            )
          end

          unless PlaceDetermination.find(
            :first,
            :conditions => {:entry_id => entry.id, :place_id => place.id}
          )
            PlaceDetermination.create(
              entry_id:        entry.id,
              place_id:        place.id,
              string:          location[:name],
              relevance_score: location[:score]
            )
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


  private

  attr_reader :entry

  def locations
    entry_text_segments.each_with_object([]) do |text_segment, responses|
      location_response = OpenCalais::ClientWrapper.new(text_segment).locations
      if location_response.present?
        responses << location_response
      end
    end.
    flatten.
    select{|location| location[:latitude] && location[:longitude] }
    #NOTE: OpenCalais sometimes sends locations without latitudes and longitudes.
  end

  def entry_text_segments
    segments    = []
    index_start = 0

    while index_start <= entry.raw_text.size
      segments << entry.raw_text.slice(index_start, CHARACTER_REQUEST_LIMIT)
      index_start += CHARACTER_REQUEST_LIMIT
    end

    segments
  end

end
