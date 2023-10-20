class Content::PublicInspectionImporter::ApiClient
  class ResponseError < StandardError
    attr_reader :response_path

    def initialize(error_message, response_path)
      @response_path = response_path
      super(error_message)
    end
  end
  class NotifiableResponseError < ResponseError; end

  include HTTParty
  headers 'Accept-Encoding' => "UTF-8"

  base_uri Rails.application.credentials.dig(:edocs, :base_url)
  USERNAME = Rails.application.credentials.dig(:edocs, :public_inspection_feed, :username)
  PASSWORD = Rails.application.credentials.dig(:edocs, :public_inspection_feed, :password)

  def initialize(options={})
    @session_token = options[:session_token]
  end

  def documents(date=Date.current)
    response = get("/eDocs/PIReport/#{date.strftime("%Y%m%d")}")
    response_body = response.body

    if parsed_json(response_body)
      file_path = write_to_log(response_body)
      raise NotifiableResponseError.new("JSON was found in the API response, when XML was expected", file_path)
    end

    if !response.ok?
      file_path = write_to_log(response_body)
      raise NotifiableResponseError.new("Status: #{response.code}; body: #{response_body}", file_path)
    end

    file_path = write_to_log(response_body)
    document = Nokogiri::XML(response_body)

    pi_docs = document.xpath('//PublicInspectionList/Document').map do |node|
      Document.new(self, node)
    end

    if pi_docs.blank?
      raise NotifiableResponseError.new("No public inspection documents found in API response", file_path)
    end

    pi_docs
  end

  def get(url)
    self.class.get(url, headers: {"SessionToken" => session_token})
  end

  def put(url)
    self.class.put(url, headers: {"SessionToken" => session_token})
  end

  def session_token
    return @session_token if @session_token

    hashed_credentials = Base64.encode64("#{USERNAME}:#{PASSWORD}")
    request_body = "Basic #{hashed_credentials}"
    response = self.class.post(
      "/authentication/login",
      :body => request_body
    )
    response_body = response.body.force_encoding("ISO-8859-1").encode("UTF-8")
    file_path = write_to_log(response_body)
    raise ResponseError.new("Status: #{response.code}; body: #{response_body}", file_path) unless response.ok?

    @session_token = JSON.parse(response_body)["SessionToken"]
  end

  def logout
    put("https://edocs.fedreg.gov/highview/webservices/authentication/logout")
  end

  private

  def parsed_json(string)
    begin
      JSON.parse(string)
    rescue JSON::ParserError
    end
  end

  def write_to_log(response_body)
    dir = FileUtils.mkdir_p("#{FileSystemPathManager.data_file_path}/public_inspection/xml/#{Time.now.strftime('%Y/%m/%d')}/")
    path = "#{dir.first.to_s}/#{Time.now.to_s(:HMS_Z)}.xml"
    f = File.new(path, "w")
    f.binmode
    f.write(response_body)
    f.close
    path
  end
end
