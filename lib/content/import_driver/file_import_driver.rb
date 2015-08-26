module Content
  class ImportDriver
    class FileImportDriver < Content::ImportDriver
      def run
        load "#{Rails.root}/Rakefile"
        Rake::Task["content:file_import:run"].invoke
      end

      def lockfile_name
        "eps_file_import_driver.lock"
      end
    end
  end
end
