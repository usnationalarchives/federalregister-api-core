namespace :content do
  namespace :entries do
    def entry_importer(*attributes)
      date = ENV['DATE_TO_IMPORT'] || Date.today
      Content::EntryImporter.process_all_by_date(date, *attributes)
    end
    
    desc "Import all entry data"
    task :import => :environment do
      entry_importer(:all)
    end
    
    namespace :import do
      desc "Extract lede photo candidates"
      task :lede_photo_candidates => :environment do
        entry_importer(:lede_photo_candidates)
      end
      
      desc "Extract CFR information into entries"
      task :cfr => :environment do
        entry_importer(:cfr_title, :cfr_part, :section_ids)
      end
    
      desc "Extract agency information into entries"
      task :agencies => :environment do
        entry_importer(:agency_name_assignments)
      end
      
      desc "Import graphics"
      task :graphics => :environment do
        date = ENV['DATE_TO_IMPORT'] || Date.today
        Content::GraphicsExtractor.new(date).perform
      end
    end
  end
end