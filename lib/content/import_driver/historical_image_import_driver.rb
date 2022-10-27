module Content
  class ImportDriver
    class HistoricalImageImportDriver < Content::ImportDriver
      def run
        rake_task_name = "content:images:download_originals_to_holding_tank"
        ENV['IMAGE_SOURCE_ID'] = ImageSource::GPO_SFTP_HISTORICAL_IMAGES.id.to_s
        Rake::Task[rake_task_name].invoke
      end

      def lockfile_name
        "historical_image_import_driver.lock"
      end

      private

      def timeout_length
        24.hours
      end
    end
  end
end
