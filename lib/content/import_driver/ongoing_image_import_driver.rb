module Content
  class ImportDriver
    class OngoingImageImportDriver < Content::ImportDriver
      def run
        rake_task_name = "content:images:download_originals_to_holding_tank"
        ENV['IMAGE_SOURCE_ID'] = ImageSource::GPO_SFTP.id.to_s
        Rake::Task[rake_task_name].invoke
      end

      def lockfile_name
        "ongoing_image_import_driver.lock"
      end

      private

      def timeout_length
        24.hours
      end
    end
  end
end
