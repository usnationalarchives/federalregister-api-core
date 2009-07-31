namespace :data do
  namespace :update do
    desc "Check all URLs to see if they are up, what their content type is, etc"
    task :urls => :environment do
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
          
        rescue Curl::Err::HostResolutionError
          url.response_code = 404
          url.content_type = nil
          url.content_length = nil
        rescue Curl::Err::TooManyRedirectsError, Curl::Err::ConnectionFailedError, Curl::Err::GotNothingError, Curl::Err::TimeoutError, Curl::Err::SSLConnectError
          url.response_code = 500
          url.content_type = nil
          url.content_length = nil
        rescue Exception => e
          raise e.inspect
        end
        
        if url.response_code == 200 && url.content_type =~ /text\/html/ #FIXME: need to check for XHTML
          c.http_get
          output = c.body_str
          doc = Nokogiri::XML(output)
          
          title_nodes = doc.css('title')
          if title_nodes && title_nodes.first
            url.title = title_nodes.first.content
          end
        end
        
        if url.changed?
          url.save
        else
          # url.touch
        end
      end
    end
  end
end