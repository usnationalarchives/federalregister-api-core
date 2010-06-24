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
      desc "Extract full text"
      task :full_text => :environment do
        entry_importer(:full_text)
      end
      
      desc "Extract full xml & full_text"
      task :full_xml_and_full_text => :environment do
        entry_importer(:full_xml, :full_text)
      end
      
      desc "Extract docket id"
      task :docket_id => :environment do
        entry_importer(:docket_id)
      end
      
      desc "Extract events"
      task :events => :environment do
        entry_importer(:events)
      end
      
      desc "Extract lede photo candidates"
      task :lede_photo_candidates => :environment do
        entry_importer(:lede_photo_candidates)
      end
      
      desc "Extract CFR information into entries"
      task :cfr => :environment do
        entry_importer(:cfr_title, :cfr_part)
      end
      
      desc "Assign entries to sections"
      task :sections => :environment do
        # entry_importer(:sections)
        sections = Section.all(:include => :agencies)
        Content.parse_dates(ENV['DATE_TO_IMPORT']).each do |date|
          puts "handling #{date}..."
          Entry.published_on(date).scoped(:include => [:agencies, :sections]).each do |entry|
            entry.section_ids = sections.select{|s| s.should_include_entry?(entry)}.map(&:id)
            entry.save
          end
        end
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