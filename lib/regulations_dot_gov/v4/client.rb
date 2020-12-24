class RegulationsDotGov::V4::Client

  def initialize
    @logger = Logger.new("#{Rails.root}/log/#{Rails.env}_regulations_dot_gov_v4.log")
  end

  def find_detailed_document(regulations_dot_gov_id)
    response = connection.get(
      "documents/#{regulations_dot_gov_id}",
      'api_key'          => api_key
    )
    data = JSON.parse(response.body).fetch('data')
    RegulationsDotGov::V4::DetailedDocument.new(data)
  end

  def find_basic_document(document_number)
    response = connection.get(
      'documents',
      'filter[frDocNum]' => document_number,
      'api_key'          => api_key
    )
    data = JSON.parse(response.body).fetch('data')
    raise if data.length != 1
    RegulationsDotGov::V4::BasicDocument.new(data.first)
  end

  def find_comments_by_comment_on_id(comment_on_id)
    response = connection.get(
      'comments',
      'filter[commentOnId]' => comment_on_id,
      'api_key'             => api_key
    )
    data = JSON.parse(response.body).fetch('meta')
    RegulationsDotGov::V4::CommentCollection.new(data)
  end

  def find_docket(docket_id)
    response = connection.get(
      "dockets/#{docket_id}",
      'api_key'             => api_key
    )
    data = JSON.parse(response.body).fetch('data')
    RegulationsDotGov::V4::Docket.new(data)
  end

  def find_documents_by_docket(docket_id)
    response = connection.get(
      'documents',
      'filter[docketId]' => docket_id,
      'api_key'          => api_key
    )
    JSON.parse(response.body)
  end

  def find_documents_updated_within(days, document_type_identifier)
    response = connection.get(
      'documents',
      'filter[lastUpdated][ge]' => (Date.current - days.days).to_s(:iso),
      'filter[documentType]'    => document_type_identifier,
      'api_key'                 => api_key
      #TODO: V3 had an rpp argument, unclear whether needed in V4.
    )
    JSON.parse(response.body)
  end


  private

  attr_reader :logger

  def api_key
    Rails.application.secrets[:regulations_dot_gov][:v4_api_key]
  end

  def connection
    Faraday.new(:url => 'https://api.regulations.gov/v4') do |faraday|
      faraday.response :logger, logger
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

end
