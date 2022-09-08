module Content
  class ImportDriver
    class StreamlinedEpsImportDriver < Content::ImportDriver
      def run
        rake_task_name = "content:images:import_eps"

        Rake::Task[rake_task_name].invoke
      end

      def lockfile_name
        "streamlined_eps_import_driver.lock"
      end
    end
  end
end
