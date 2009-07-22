task :update_urls => :environment do
  Url.find(:all, :conditions => ["updated_at < ?", 1.minute.ago]).each do |url|
    puts "checking #{url.name}..."
    begin
      c = Curl::Easy.new(url.name)
      c.follow_location = true
      c.max_redirects = 5
      c.timeout = 5
      # c.headers["User-Agent"] = "myapp-0.0"
    
      c.http_head
    
      url.response_code = c.response_code
      url.content_type =  c.content_type
      url.content_length = c.downloaded_content_length > 0 ? c.downloaded_content_length : nil
    
    rescue Curl::Err
      url.response_code = 404
    end
    
    if url.changed?
      url.save
    else
      # url.touch
    end
  end
end