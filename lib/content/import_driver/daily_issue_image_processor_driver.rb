module Content
  class ImportDriver
    class DailyIssueImageProcessorDriver < Content::ImportDriver
      def run
        load "#{Rails.root}/Rakefile"
        Rake::Task["content:gpo_images:process_daily_issue_images_raw_task"].invoke
      end

      def lockfile_name
        "daily_issue_image_processor_driver.lock"
      end
    end
  end
end
