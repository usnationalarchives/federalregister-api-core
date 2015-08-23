namespace :content do
  namespace :eps_import do

    desc "Run the driver"
    task :import => :environment do
      Content::ImportDriver::EpsImageImportDriver.new.perform
    end

    desc "Run the importer"
    task :run => :environment do
      GpoImages::EpsImporter.run
    end

  end
end
