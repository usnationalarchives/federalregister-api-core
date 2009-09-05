namespace :data do
  namespace :extract do
    desc "Extract citations from entries for a particular date"
    task :citations => :environment do 
    end
    
    desc "Extract citations from all entries"
    task :all_citations => :environment do
      Entry.find_each do |entry|
        puts "extracting citations for #{entry.document_number} (#{entry.publication_date})"
        Citation.extract!(entry)
      end
    end
  end
end
