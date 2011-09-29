namespace :content do
  namespace :public_inspection do
    desc "Import current public inspection data"
    task :import => :environment do
      Content::PublicInspectionImporter.perform
    end
  end
end
