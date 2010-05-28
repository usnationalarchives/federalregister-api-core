namespace :content do
  namespace :agencies do
    desc "Import all GPO agencies from CSV"
    task :import => :environment do
      Content::AgencyImporter.new.perform
    end
    
    desc "Match agency names"
    task :match_names => :environment do
      Content::NameMatcher::Agencies.new.perform
    end
  end
end