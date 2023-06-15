class PlaceDeterminer
  extend Memoist
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :place_determiner, :retry => 0
  # NOTE: The intent is to use sidekiq_throttled to meter how frequently jobs are enqueued, not the daily API call limit
  sidekiq_throttle(
    concurrency: {
      limit: Settings.open_calais.throttle.concurrency
    },
    threshold: {
      limit:  Settings.open_calais.throttle.at,
      period: Settings.open_calais.throttle.per,
    }
  )

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

          unless PlaceDetermination.find_by(
            entry_id: entry.id,
            place_id: place.id
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
    rescue OpenCalais::ClientWrapper::RequestLimit
      # Don't send failures to dead jobs queue since these jobs regularly fail
    end
  end


  private

  attr_reader :entry

  def locations
    entry_text_segments.each_with_object([]).with_index do |(text_segment, responses), i|
      location_response = OpenCalais::ClientWrapper.new(text_segment).locations
      if location_response.present?
        responses << location_response
      end
      if i != last_index
        sleep Settings.open_calais.throttle.per
      end
    end.
    flatten.
    select{|location| location[:latitude] && location[:longitude] }
    #NOTE: OpenCalais sometimes sends locations without latitudes and longitudes.
  end

  def last_index
    entry_text_segments.size - 1
  end

  MAX_OPEN_CALAISE_FILE_SIZE_IN_KILOBYTES = 100 #Per Open Calais documentation
  def entry_text_segments
    entry.raw_text.chars.each_slice(slice_size).map(&:join)
  end

  def slice_size
    (entry.raw_text.size / chunks.to_f).ceil
  end
  memoize :slice_size

  def chunks
    (raw_text_size_in_kilobytes / MAX_OPEN_CALAISE_FILE_SIZE_IN_KILOBYTES).ceil
  end

  def raw_text_size_in_kilobytes
    File.size(entry.raw_text_file_path).to_f / 1000
  end

end
