class GovInfoClient
  class PaiPackage < OpenStruct

    def year
      title.split(',').last.strip.to_i
    end

    def agency_name
      title.
        gsub(/privacy act issuanc(e|es) for the /i,"").
        gsub(/,\s*\d{4}$/, "")
    end

    def pai_identifier
      packageId.
        gsub(/^PAI-\d{4}-/, '').
        gsub(/-interim/, "") # ignore whether package is an interim collection
    end

  end


  def self.last_modified_fr_collections(url_params:, result_klass:)
    new.collections('FR', url_params: url_params, result_klass: result_klass)
  end

  def collections(collection_identifier, url_params: {}, result_klass:)
    # eg "https://api.govinfo.gov/collections/FR/2023-05-01T00%3A00%3A00Z?pageSize=100&offsetMark=*&api_key=DEMO_KEY"
    raise "Please provide a last modified start date" unless url_params[:last_modified_start_date]

    last_modified_start_date = url_params[:last_modified_start_date].is_a?(Date) ? url_params.delete(:last_modified_start_date) : Date.parse(url_params.delete(:last_modified_start_date))

    response = connection.get(
      "collections/#{collection_identifier}/#{last_modified_start_date.to_time.utc.iso8601}",
      standard_options.merge(url_params)
    )

    collection = []
    if response.success?
      packages = JSON.parse(response.body, object_class: result_klass).packages || []
      collection = collection + packages
      next_page = JSON.parse(response.body)["nextPage"]
      while next_page
        response = connection.get("#{next_page}&api_key=#{api_key}")
        next_page = JSON.parse(response.body)["nextPage"]
        packages = JSON.parse(response.body, object_class: PaiPackage).packages || []
        collection = collection + packages
      end
    else
      body = JSON.parse(response.body, object_class: OpenStruct)

      Honeybadger.notify("Govinfo API error: #{response.status}: #{body.error}")
    end

    collection
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
    Rails.application.credentials.dig(:gpo, :gov_info, :api_key)
  end

  def connection
    Faraday.new(:url => 'https://api.govinfo.gov/') do |faraday|
      # faraday.response :logger, logger
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

end
