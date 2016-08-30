namespace :data do
  namespace :migrate do
    task :curated => :environment do
      DataMigrator.new.copy_curated
    end

    task :core => :environment do
      DataMigrator.new.copy_core_data
    end
  end
end
