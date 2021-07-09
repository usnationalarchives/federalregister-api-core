module Content
  class ImportDriver
    class PublicInspectionDriver < Content::ImportDriver
      def run
        Rake::Task["content:public_inspection:run"].invoke
      end

      def lockfile_name
        "import_public_inspection.lock"
      end
    end
  end
end

