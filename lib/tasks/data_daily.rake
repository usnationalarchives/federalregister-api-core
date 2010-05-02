namespace :content do
  namespace :agencies do
    desc "Import official GPO agency list"
    task :agencies => :environment do
      date = ENV['DATE_TO_IMPORT'] || Date.today
      Content::EntryImporter.process_all_by_date(date, :agency_name_assignments)
    end
  end
end