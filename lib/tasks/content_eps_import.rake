namespace :content do
  namespace :eps_import do

    desc "Run the driver"
    task :import => :environment do
      Content::ImportDriver::EpsImportDriver.new.perform
    end

    desc "Download GPO images and move them to S3."
    task :run => :environment do
      GpoImages::EpsImporter.run
    end

  end

  namespace :file_import do

    desc "Run the driver"
    task :import => :environment do
      Content::ImportDriver::FileImportDriver.new.perform
    end

    desc "Download the .eps images from S3, convert them, and upload them to FR app-specific S3 bucket."
    task :run => :environment do
      GpoImages::FileImporter.run
    end

  end
end
