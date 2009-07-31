namespace :data do
  namespace :download do
    desc "Download full text of entries and store in entries.full_text_raw"
    task :full_text => :environment do
      Entry.find(:all, :conditions => {:full_text => nil}).each do |entry|
        url = entry.source_url(:text)
        puts "downloading full text for #{entry.document_number} (#{entry.publication_date})"
        c = Curl::Easy.new(url)
        c.http_get
        if c.response_code == 200
          entry.full_text_raw = c.body_str
          entry.save
        end
      end
    end
  end
end