module Content
  class ImportDriver
    class EpsImportDriver < Content::ImportDriver
      def run
        load "#{Rails.root}/Rakefile"
        Rake::Task["content:gpo_images:import_eps_raw_task"].invoke
      end

      def lockfile_name
        "eps_import_driver.lock"
      end
    end
  end
end
