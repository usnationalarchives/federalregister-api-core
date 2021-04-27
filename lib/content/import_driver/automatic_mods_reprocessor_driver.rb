module Content
  class ImportDriver
    class AutomaticModsReprocessorDriver < Content::ImportDriver
      load './lib/tasks/content_issues.rake'

      def run
        Rake::Task["content:issues:auto_import_mods"].invoke
      end

      def lockfile_name
        "automatic_mods_reprocessor.lock"
      end
    end
  end
end
