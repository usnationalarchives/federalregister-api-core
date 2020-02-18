module Content
  class ImportDriver
    class EpsImportDriver < Content::ImportDriver
      load './lib/tasks/content_eps_import.rake'

      def run
        Rake::Task["content:gpo_images:import_eps"].invoke
      end

      def lockfile_name
        "eps_import_driver.lock"
      end
    end
  end
end
