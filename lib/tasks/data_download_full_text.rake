namespace :data do
  namespace :download do
    desc "Download full text of entries and store in entries.full_text_raw"
    task :full_text => :environment do
      date = ENV['DATE_TO_IMPORT'].blank? ? Date.today : Date.parse(ENV['DATE_TO_IMPORT'])
      
      Entry.all(:conditions => {:publication_date => date}).each do |entry|
        entry_detail = entry.entry_detail
        next unless entry_detail.full_text_raw.nil?
        url = entry.source_url(:text)
        puts "downloading full text for #{entry.document_number} (#{entry.publication_date})"
        full_text = nil
        
        c = Curl::Easy.new(url)
        c.http_get
        
        15.times do
          if c.response_code == 200 && c.body_str !~ /^<html xmlns/
            full_text = c.body_str
            break
          else
            sleep 0.5
          end
        end
        
        if full_text
          entry.source_text_url = url
          entry.save
        
          entry_detail.full_text_raw = c.body_str
          entry_detail.save
          
          Citation.extract!(entry)
        end
      end
    end
  end
end