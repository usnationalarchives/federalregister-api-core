namespace :content do
  namespace :eps_import do

    desc "Run the driver"
    task :import => :environment do
      Content::ImportDriver::EpsImportDriver.new.perform
    end

    desc "Run the importer"
    task :run => :environment do
      GpoImages::EpsImporter.run
    end

  end

  namespace :file_import do

    desc "Run the driver"
    task :import => :environment do
      Content::ImportDriver::FileImportDriver.new.perform
    end

    desc "Run the importer"
    task :run => :environment do
      GpoImages::FileImporter.run
    end

  end
end
