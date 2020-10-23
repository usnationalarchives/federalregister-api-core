class RegulationsDotGov::V4::Client

  def initialize
    @logger = Logger.new("#{Rails.root}/log/#{Rails.env}_regulations_dot_gov_v4.log")
  end

  def find_detailed_document(regulations_dot_gov_id)
    response = connection.get(
      "v4/documents/#{regulations_dot_gov_id}",
      'api_key'          => api_key
    )
    data = JSON.parse(response.body).fetch('data')
    RegulationsDotGov::V4::DetailedDocument.new(data)
  end

  def find_basic_document(document_number)
    response = connection.get(
      'v4/documents',
      'filter[frDocNum]' => document_number,
      'api_key'          => api_key
    )
    data = JSON.parse(response.body).fetch('data')
    raise if data.length != 1
    RegulationsDotGov::V4::BasicDocument.new(data.first)
  end

  def find_comments_by_comment_on_id(comment_on_id)
    response = connection.get(
      'v4/comments',
      'filter[commentOnId]' => comment_on_id,
      'api_key'             => api_key
    )
    data = JSON.parse(response.body).fetch('meta')
    RegulationsDotGov::V4::CommentCollection.new(data)
  end

  private

  attr_reader :logger

  def api_key
    Rails.application.secrets[:regulations_dot_gov][:v4_api_key]
  end

  def connection
    Faraday.new(:url => 'https://api.regulations.gov') do |faraday|
      faraday.response :logger, logger
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

end
