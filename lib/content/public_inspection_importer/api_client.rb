class Content::PublicInspectionImporter::ApiClient
  class ResponseError < StandardError; end

  include HTTParty
  headers 'Accept-Encoding' => "UTF-8"

  base_uri SECRETS['public_inspection']['api_base_uri']
  USERNAME = SECRETS['public_inspection']['api_user_name']
  PASSWORD = SECRETS['public_inspection']['api_password']

  def initialize(options={})
    @session_token = options[:session_token]
  end

  def documents(date=Date.current)
    response = get("/eDocs/PIReport/#{date.strftime("%Y%m%d")}")
    response_body = response.body
    raise ResponseError.new("Status: #{response.code}; body: #{response_body}") unless response.ok?

    write_to_log(response_body)
    document = Nokogiri::XML(response_body)

    document.xpath('//PublicInspectionList/Document').map do |node|
      Document.new(self, node)
    end
  end

  def get(url)
    self.class.get(url, :headers => {"SessionToken" => session_token})
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
    raise ResponseError.new("Status: #{response.code}; body: #{response_body}") unless response.ok?

    @session_token = JSON.parse(response_body)["SessionToken"]
  end

  private

  def write_to_log(response_body)
    dir = FileUtils.mkdir_p("#{FileSystemPathManager.data_file_path}/public_inspection/xml/#{Time.now.strftime('%Y/%m/%d')}/")
    f = File.new("#{dir.first.to_s}/#{Time.now.to_s(:HMS_Z)}.xml", "w")
    f.binmode
    f.write(response_body)
    f.close
  end
end
