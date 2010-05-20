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
      desc "Extract referenced dates"
      task :referenced_dates => :environment do
        entry_importer(:referenced_dates)
      end
      
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
        # evetually logic needs to be moved into entryimporter...
        date = ENV['DATE_TO_IMPORT']
        
        if date.nil?
          dates = [Date.today]
        elsif date == 'all'
          dates = Entry.find_as_array(
            :select => "distinct(publication_date) AS publication_date",
            :order => "publication_date"
          )
        elsif date =~ /^>/
          date = Date.parse(date.sub(/^>/, ''))
          dates = Entry.find_as_array(
            :select => "distinct(publication_date) AS publication_date",
            :conditions => {:publication_date => date .. Date.today},
            :order => "publication_date"
          )
        elsif date =~ /^\d{4}$/
          dates = Entry.find_as_array(
            :select => "distinct(publication_date) AS publication_date",
            :conditions => {:publication_date => Date.parse("#{date}-01-01") .. Date.parse("#{date}-12-31")},
            :order => "publication_date"
          )
        elsif date =~ /^\d{4}-\d{2}-\d{2}$/
          dates = [date]
        else
          raise "INVALID FORMAT"
        end
        
        dates.each do |date|
          Content::GraphicsExtractor.new(date).perform
        end
        
      end
    end
  end
end