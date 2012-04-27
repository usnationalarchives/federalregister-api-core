namespace :content do
  namespace :executive_orders do
    desc "Import corrected executive order data"
    task :import => :environment do
      Content::ExecutiveOrderImporter.perform
    end
  end
end
