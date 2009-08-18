namespace :data do
  namespace :download do
    desc "Download full text of entries and store in entries.full_text_raw"
    task :full_text => :environment do
      Entry.all(:conditions => {:publication_date => Entry.latest_publication_date}).each do |entry|
        entry_detail = entry.entry_detail
        next unless entry_detail.full_text_raw.nil?
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
        entry.save
        
        entry_detail.full_text_raw = c.body_str
        entry_detail.save
      
      end
    end
  end
end