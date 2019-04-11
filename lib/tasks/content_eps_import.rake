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

    desc "Rename all images to use the XML identfier"
    task :update_image_names_using_xml_identifier => :environment do
      gpo_graphics = GpoGraphic.find(
        :all,
        :include => [:gpo_graphic_usages],
        :conditions => "gpo_graphic_usages.xml_identifier IS NOT NULL && gpo_graphics.graphic_file_name IS NOT NULL"
      )

      aws_conn = GpoImages::FogAwsConnection.new

      gpo_graphics.each do |gpo_graphic|
        xml_identifier = gpo_graphic.gpo_graphic_usages.first.xml_identifier

        if gpo_graphic.graphic_file_name.gsub(/.eps/i, '') != xml_identifier
          aws_conn.move_directory_files_between_buckets_and_rename(
            xml_identifier,
            gpo_graphic.identifier,
            gpo_graphic.send(:public_bucket),
            gpo_graphic.send(:public_bucket)
          )
          gpo_graphic.update_attribute(
            :graphic_file_name,
            gpo_graphic.graphic_file_name.gsub(gpo_graphic.identifier, xml_identifier)
          )
        end
      end
    end
  end
end
