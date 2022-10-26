namespace :content do

  namespace :images do
    desc "Lock-safe version of import_eps task"
    task :lock_safe_import_eps => :environment do
      Content::ImportDriver::StreamlinedEpsImportDriver.new.perform
    end

    desc "Download images from SFTP and save them to the image holding tank"
    task :import_eps => :environment do
      ImagePipeline::SftpDownloader.new(image_source_id: ImageSource::GPO_SFTP_HISTORICAL_IMAGES.id).perform
    end

    desc "Enqueue environment-specific jobs for downloading/processing from the image holding tank"
    task :enqueue_environment_specific_image_downloads => :environment do
      enqueued_s3_keys = Set.new
      Sidekiq::Queue.new('gpo_image_import').each do |job|
        enqueued_s3_keys << job.args.first
      end

      GpoImages::FogAwsConnection.
        new.
        connection.
          directories.new(:key => SETTINGS['s3_buckets']['image_holding_tank']).
          files.
          map{|file| file.key}.
          select{|s3_key| enqueued_s3_keys.exclude?(s3_key) }.
          select{|s3_key| s3_key.include?('.')}.
          each do |s3_key|
            ImagePipeline::EnvironmentImageDownloader.perform_async(s3_key)
          end
    end

    desc "Migrate gpo_graphics table to images table"
    task :migrate_gpo_graphics => :environment do
      GpoGraphic.
        find_each do |graphic|
          GpoGraphicMigrator.perform_async(graphic.identifier)
        end
    end

    desc "Migrate historical (pre ~2015) graphics table to images table"
    task :migrate_historical_graphics => :environment do
      Graphic.
        find_each do |graphic|
          GraphicMigrator.perform_async(graphic.id)
        end
    end

    desc "Create image usages"
    task :import_image_usages => :environment do
      Entry.
        where("publication_date >= '2000-01-01'").
        order(publication_date: :desc).
        pluck(:publication_date).
        uniq.
        each do |publication_date|
          DailyIssueImageUsageBuilder.perform_async(publication_date.to_s(:iso))
        end
    end

    desc "Create cloudfront image invalidation"
    task :create_cloudfront_invalidation => :environment do
      Image.
        find_by_identifier!(ENV['IMAGE_IDENTIFIER'].try(:upcase)).
        invalidate_image_identifier_keyspace!
    end

  end

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
          DailyIssueImageUsageBuilder.new.perform(date)
        rescue StandardError => e
          puts e.message
          puts e.backtrace.join("\n")
          Honeybadger.notify(e, error_message: "An error occurred while creating image usages/marking them as public for the #{date} issue.  Make sure the DailyIssueImageUsageBuilder succeeds to ensure relevant images are made public for the issue.")
        end
      end
    end

    desc "Identify unlinked GPO images where the image identifier has been found in document XML, rescan the associated documents and "
    task :reprocess_unlinked_gpo_images => :environment do
      GpoImages::UnlinkedImageReprocessor.perform
    end

  end
end
