namespace :content do
  namespace :executive_orders do
    desc "Import corrected executive order data"
    task :import => :environment do
      Content::ExecutiveOrderImporter.perform("data/executive_orders.csv")
    end
  end
end
