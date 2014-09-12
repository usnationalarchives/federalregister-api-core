class Content::PublicInspectionImporter::ApiClient
  class ResponseError < StandardError; end

  include HTTParty
  headers 'Accept-Encoding' => "UTF-8"
  debug_output

  base_uri SECRETS['pil_api_base_uri']
  USERNAME = SECRETS['pil_api_user_name']
  PASSWORD = SECRETS['pil_api_password']

  def initialize(options={})
    @session_token = options[:session_token]
  end

  def documents(date=Date.today)
    response = get("/eDocs/PIReport/#{date.strftime("%Y%m%d")}")
    raise ResponseError.new("Status: #{response.code}; body: #{response.body}") unless response.ok?

    write_to_log(response)
    document = Nokogiri::XML(response.body)

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
    raise ResponseError.new("Status: #{response.code}; body: #{response.body}") unless response.ok?

    @session_token = JSON.parse(response.body)["SessionToken"]
  end

  private

  def write_to_log(response)
    dir = FileUtils.mkdir_p("#{Rails.root}/data/public_inspection/xml/#{Time.now.strftime('%Y/%m/%d')}/")
    f = File.new("#{dir.to_s}/#{Time.now.to_s(:HMS_Z)}.xml", "w")
    f.write(response.body)
    f.close
  end
end
