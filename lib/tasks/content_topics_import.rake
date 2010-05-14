namespace :content do
  namespace :topics do
    desc "Import all Topics from CFR index"
    task :import => :environment do
      Content::TopicImporter.new.perform
    end
  end
end