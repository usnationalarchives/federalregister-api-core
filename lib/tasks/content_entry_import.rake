namespace :content do
  namespace :entries do
    namespace :import do
      desc "Extract CFR information into entries"
      task :cfr => :environment do
        date = ENV['DATE_TO_IMPORT'] || Date.today
        Content::EntryImporter.process_all_by_date(date, :cfr_title, :cfr_part, :section_ids)
      end
    
      desc "Extract agency information into entries"
      task :agencies => :environment do
        date = ENV['DATE_TO_IMPORT'] || Date.today
        Content::EntryImporter.process_all_by_date(date, :agency_name_assignments)
      end
    end
  end
end