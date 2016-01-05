namespace :data do
  namespace :download do
    desc "Download full text of entries and store in entries.full_text_raw"
    task :full_text => :environment do
      date = ENV['DATE'].blank? ? Time.current.to_date : Date.parse(ENV['DATE'])
      
      Entry.all(:conditions => {:publication_date => date}).each do |entry|
        # next if entry.full_text_updated_at.present?
        url = entry.source_url(:text)
        puts "downloading full text for #{entry.document_number} (#{entry.publication_date})"
        full_text = nil

        c = FederalRegisterFileRetriever.http_get(url)

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
          entry.full_text = c.body_str
          entry.save
          
          Citation.extract!(entry)
        end
      end
    end
  end
end