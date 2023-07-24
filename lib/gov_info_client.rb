class GovInfoClient

  def self.last_modified_fr_collections(args={last_modified_start_date: Date.current - 1.day})
    new.fr_collections(args)
  end

  def fr_collections(args={})
    # eg "https://api.govinfo.gov/collections/FR/2023-05-01T00%3A00%3A00Z?pageSize=100&offsetMark=*&api_key=DEMO_KEY"
    raise "Please provide a last modified start date" unless args[:last_modified_start_date]

    last_modified_start_date = args[:last_modified_start_date].is_a?(Date) ? args.delete(:last_modified_start_date) : Date.parse(args.delete(:last_modified_start_date))

    response = connection.get(
      "collections/FR/#{last_modified_start_date.to_time.utc.iso8601}",
      standard_options.merge(args)
    )
   
    if response.success?
      JSON.parse(response.body, object_class: OpenStruct).packages || []
    else
      body = JSON.parse(response.body, object_class: OpenStruct)

      Honeybadger.notify("Govinfo API error: #{response.status}: #{body.error}")
      []
    end
  end

  private


  def standard_options
    {api_key: api_key, pageSize: page_size, offsetMark: offset_mark}
  end

  def offset_mark
    "*"
  end

  def page_size
    1000
  end

  def api_key
    Rails.application.secrets[:api_keys][:gov_info]
  end

  def connection
    Faraday.new(:url => 'https://api.govinfo.gov/') do |faraday|
      # faraday.response :logger, logger
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

end
