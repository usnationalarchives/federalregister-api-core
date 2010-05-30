namespace :content do
  namespace :regulatory_plans do
    desc "import regulatory plans"
    task :import => :environment do 
      Content::RegulatoryPlanImporter.import_all_by_publication_date(ENV['ISSUE_TO_IMPORT'])
    end
  end
end