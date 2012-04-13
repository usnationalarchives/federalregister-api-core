namespace :content do
  namespace :executive_orders do
    task :import => :environment do
      Content::ExecutiveOrderImporter.perform
    end
  end
end
