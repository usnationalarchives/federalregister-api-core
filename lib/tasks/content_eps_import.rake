namespace :content do
  namespace :gpo_images do

    desc "Import images from the GPO FTP drive"
    task :import => :environment do
      Content::ImportDriver::EpsImportDriver.new.perform
    end

    desc "Download GPO images and move them to S3."
    task :import_eps => :environment do
      GpoImages::EpsImporter.run
    end

    desc "Convert eps files to images"
    task :convert => :environment do
      Content::ImportDriver::FileImportDriver.new.perform
    end

    desc "Download the .eps images from S3, convert them, and upload them to FR app-specific S3 bucket."
    task :convert_eps => :environment do
      dates = Content.parse_all_dates(ENV['DATE'])

      dates.each do |date|
        GpoImages::FileImporter.run(date)
      end
    end

    desc "Delete the date's redis keys and re-execute the eps_conversion process."
    task :force_convert_eps => :environment do
      dates = Content.parse_all_dates(ENV['DATE'])

      dates.each do |date|
        GpoImages::FileImporter.force_convert(date)
      end
    end

    desc "Scan through the most recent issue's XML -- noting image usages and moving images to public buckets accordingly"
    task :process_daily_issue_images => :environment do
      dates = Content.parse_all_dates(ENV['DATE'])

      dates.each do |date|
        begin
          puts "linking GPO images for #{date}"
          GpoImages::DailyIssueImageProcessor.perform(date)
        rescue StandardError => e
          puts e.message
          puts e.backtrace.join("\n")
          Honeybadger.notify(e)
        end
      end
    end

    desc "Identify unlinked GPO images where the image identifier has been found in document XML, rescan the associated documents and "
    task :reprocess_unlinked_gpo_images => :environment do
      GpoImages::UnlinkedImageReprocessor.perform
    end

  end
end
