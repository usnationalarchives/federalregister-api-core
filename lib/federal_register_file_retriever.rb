class FederalRegisterFileRetriever
  def self.download(url, path)
    puts "downloading #{url} to #{path}"

    Curl::Easy.download(url, path) do |c|
      c.follow_location = follow_location
      c.headers["User-Agent"] = user_agent
    end
  end

  def self.http_get(url)
    Curl::Easy.http_get(url) do |c|
      c.follow_location = follow_location
      c.headers["User-Agent"] = user_agent
    end
  end

  def self.user_agent
    "FederalRegister.gov"
  end

  def self.follow_location
    true
  end
end
