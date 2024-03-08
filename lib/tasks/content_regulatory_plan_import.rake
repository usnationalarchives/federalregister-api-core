namespace :content do
  namespace :regulatory_plans do
    desc "Import semi-annual unified agenda"
    task :schedule => :environment do
      Content::RegulatoryPlanImporterScheduler.new.perform
    end

    desc "Reimport the currently-stored issue"
    task :import_currently_stored_issue => :environment do
      Content::RegulatoryPlanImporterScheduler.reimport_currently_stored_issue
    end

    desc "import regulatory plans"
    task :import => :environment do
      Content::RegulatoryPlanImporter.import_all_by_publication_date(ENV['ISSUE_TO_IMPORT'])
    end

    desc "import all small entities for all regulatory plans"
    task :import_all_small_entities => :environment do
      Content::RegulatoryPlanImporter.import_all_small_entities
    end

    desc "recalculate the current regulatory plans"
    task :recalculate_current => :environment do
      Content::RegulatoryPlanImporter.recalculate_current
    end
  end
end
