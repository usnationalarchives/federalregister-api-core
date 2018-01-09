class FederalRegisterFileRetriever
  DEFAULT_TIMEOUT = 60

  def self.download(url, path)
    puts "downloading #{url} to #{path}"

    temp_path = Tempfile.new

    Curl::Easy.download(url, temp_path) do |c|
      c.follow_location = follow_location
      c.timeout = DEFAULT_TIMEOUT
      c.headers["User-Agent"] = user_agent
      c.on_missing{|c, code| notify_error(c, code, url)}
      c.on_failure{|c, code| notify_error(c, code, url)}
    end

    FileUtils.mv temp_file, path
  end

  def self.http_get(url)
    Curl::Easy.http_get(url) do |c|
      c.follow_location = follow_location
      c.timeout = DEFAULT_TIMEOUT
      c.headers["User-Agent"] = user_agent
      c.on_missing{|c, code| notify_error(c, code, url)}
      c.on_failure{|c, code| notify_error(c, code, url)}
    end
  end

  def self.user_agent
    "FederalRegister.gov"
  end

  def self.follow_location
    true
  end

  private

  def self.notify_error(curl, code, url)
    Honeybadger.notify(
      error_class: 'FederalRegisterFileRetriever::DownloadError',
      error_message: "Problem downloading #{url}",
      context: {
        code: code,
        curl: curl,
        url: url,
      }
    )
  end
end
