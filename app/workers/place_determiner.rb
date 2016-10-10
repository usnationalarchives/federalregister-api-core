class PlaceDeterminer
  @queue = :default

  def self.perform(entry_id)
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

          unless PlaceDetermination.all_confidences.find(
            :first,
            :conditions => {:entry_id => entry.id, :place_id => place.id}
          )
            PlaceDetermination.create(
              entry_id: entry.id,
              place_id: place.id,
              string: location[:name],
              confidence: location[:score]
            )
          end
        end
      end

    end
  end
end
