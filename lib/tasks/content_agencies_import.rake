namespace :content do
  namespace :agencies do
    desc "Import all GPO agencies from CSV"
    task :import do
      Content::AgencyImporter.perform
    end
  end
end