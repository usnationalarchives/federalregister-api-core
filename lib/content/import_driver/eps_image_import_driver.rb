module Content
  class ImportDriver
    class EpsImageImportDriver < Content::ImportDriver
      def run
        load "#{Rails.root}/Rakefile"
        Rake::Task["content:eps_import:run"].invoke
      end

      def lockfile_name
        "eps_import_driver.lock"
      end
    end
  end
end
