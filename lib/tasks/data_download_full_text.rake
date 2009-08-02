namespace :data do
  namespace :download do
    desc "Download full text of entries and store in entries.full_text_raw"
    task :full_text => :environment do
      Entry.find_in_batches(:all, :conditions => {:full_text_raw => nil}).each do |entry_group|
        entry_group.each do |entry|
          url = entry.source_url(:text)
          puts "downloading full text for #{entry.document_number} (#{entry.publication_date})"
          c = Curl::Easy.new(url)
          c.http_get
          if c.response_code != 200
            url = url + 'l' # sometimes the URL ends in .html, sometimes in .htm
            c = Curl::Easy.new()
            c.http_get
          
            if c.response_code != 200
              puts "\tnot found!"
              next
            end
          end
        
          entry.source_text_url = url
          entry.full_text_raw = c.body_str
          entry.save
        
        end
      end
    end
  end
end