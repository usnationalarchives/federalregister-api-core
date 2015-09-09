module Content
  class ImportDriver
    class FileImportDriver < Content::ImportDriver
      def run
        load "#{Rails.root}/Rakefile"
        Rake::Task["content:gpo_images:convert_eps_raw_task"].invoke
      end

      def lockfile_name
        "eps_file_import_driver.lock"
      end
    end
  end
end
