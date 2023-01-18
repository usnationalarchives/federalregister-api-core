class RegulationsDotGov::V4::Client
  class OverRateLimitError < StandardError; end
  class BadGateway < StandardError; end
  class UnhandledConnectionError < StandardError; end
  class NotFoundError < StandardError; end

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

    if data.length == 0
      return nil
    elsif data.length == 1
      RegulationsDotGov::V4::BasicDocument.new(data.first)
    else
      docs_open_for_comment = data.select{|x| x.fetch("attributes").fetch("openForComment") }
      if docs_open_for_comment.present?
        doc = docs_open_for_comment.first
      else
        doc = data.first
      end

      RegulationsDotGov::V4::BasicDocument.new(doc)
    end
  end

  def find_comments_by_regs_dot_gov_document_id(regulations_dot_gov_document_number)
    # https://api.regulations.gov/v4/document-comments-received-counts/HHS-OCR-2021-0006-0001?api_key=DEMO_KEY
    data = request_with_retry do
      connection.get(
        "document-comments-received-counts/#{regulations_dot_gov_document_number}",
        'api_key'             => api_key
      )
    end.fetch('data')
    RegulationsDotGov::V4::CommentCollection.new(data)
  end

  def find_docket(docket_id)
    response = connection.get(
      "dockets/#{docket_id}",
      'api_key'             => api_key
    )
    parsed_response = JSON.parse(response.body)
    if parsed_response['errors']
      Honeybadger.notify(
        'Unable to locate docket at reg.gov',
        context: {docket_id: docket_id, response: parsed_response}
      )
      nil
    elsif parsed_response.dig('error','code') == "OVER_RATE_LIMIT"
      raise OverRateLimitError
    else
      if parsed_response['data'].blank?
        Honeybadger.notify("'data' key missing", context: parsed_response)
      end
      RegulationsDotGov::V4::Docket.new(parsed_response.fetch('data'))
    end
  end

  def find_documents_by_docket(docket_id)
    request_with_retry do
      connection.get(
        'documents',
        'filter[docketId]' => docket_id,
        'api_key'          => api_key
      )
    end
  end


  PAGE_SIZE = 250
  MAX_PAGES = 10
  def find_documents_updated_within(days, document_type_identifier)
    hour_count = if days == 0 #The concept of 0 days is an artifact of the way the V3 API was queried where 0 days used to indicate the last 24 hours.
      24
    else
      days * 24
    end
    time = (Time.now - hour_count.hours).to_s(:db)
    documents       = []
    page_number     = 1
    parsed_response = nil

    default_query_params = {
      'filter[lastModifiedDate][ge]' => time, #NOTE: Reg.gov calls this parameter 'lastModifiedDate', but it only accepts timestamps.
      'filter[documentType]'         => document_type_identifier,
      'api_key'                      => api_key,
      'page[size]'                   => PAGE_SIZE,
      'page[number]'                 => page_number
    }

    while (page_number == 1 || parsed_response.fetch("meta").fetch("hasNextPage") )
      response = connection.get(
        'documents',
        **(default_query_params.merge('page[number]' => page_number))
      )
      parsed_response = JSON.parse(response.body)

      parsed_response.
        fetch("data").
        each {|raw_attributes| documents << RegulationsDotGov::V4::BasicDocument.new(raw_attributes) }
      page_number += 1

      if page_number > MAX_PAGES
        break
        Honeybadger.notify("More than #{MAX_PAGES} pages of results were encountered--aborted paging through results.")
      end
    end

    documents
  end

  def find_comments(args)
    response = connection.get(
      'comments',
      standard_options.merge(args)
    )
    parsed_response = JSON.parse(response.body)
    parsed_response.
      fetch("data").
      map{|raw_attributes| RegulationsDotGov::V4::Comment.new(raw_attributes) }
  end

  private

  attr_reader :logger

  RETRY_LIMIT = 1
  def request_with_retry
    retries = 0

    begin
      response = yield
      case response.status
      when 200
        JSON.parse(response.body)
      when 404
        raise NotFoundError
      when 502
        raise BadGateway
      else
        raise UnhandledConnectionError.new("#{response.status}/#{response.reason_phrase}")
      end
    rescue Faraday::ConnectionFailed, BadGateway => e
      if retries < RETRY_LIMIT
        retries += 1
        retry
      else
        raise e
      end
    end
  end

  def standard_options
    {:api_key => api_key}
  end

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
