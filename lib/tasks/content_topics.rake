namespace :content do
  namespace :topics do
    desc "Import all Topics from CFR index"
    task :import => :environment do
      Content::TopicImporter.new.perform
    end
    
    desc "Match topic names"
    task :match_names => :environment do
      Content::NameMatcher::Topics.new.perform
    end
  end
end