namespace :content do
  namespace :agencies do
    desc "Import all GPO agencies from CSV"
    task :import => :environment do
      Content::AgencyImporter.new.perform
    end
  end
end