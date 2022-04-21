module Content
  class ImportDriver
    class EpsImportDriver < Content::ImportDriver
      def run
        if SETTINGS['feature_flags']['streamlined_image_pipeline']
          rake_task_name = "content:images:import_eps_lock_safe"
        else
          rake_task_name = "content:gpo_images:import_eps"
        end

        Rake::Task[rake_task_name].invoke
      end

      def lockfile_name
        "eps_import_driver.lock"
      end
    end
  end
end
