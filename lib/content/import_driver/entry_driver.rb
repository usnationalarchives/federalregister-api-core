module Content
  class ImportDriver
    class EntryDriver < Content::ImportDriver
      def initialize
        super
        calculate_date_to_import!
      end
      
      def run
        begin
          load "#{Rails.root}/Rakefile"
          Rake::Task["data:daily:full"].invoke
        rescue Content::EntryImporter::ModsFile::DownloadError
          raise "Problem downloading mods file"
        rescue Content::EntryImporter::BulkdataFile::DownloadError
          raise "Problem downloading bulkdata file"
        end
      end
        
      def should_run?
        if import_is_complete?
          puts "Import already complete. Exiting."
          return false
        else
          return true
        end
      end

      def calculate_date_to_import!
        ENV['DATE'] = Issue.next_date_to_import.to_s(:iso)
      end
    
      def import_is_complete?
        Issue.complete?(ENV['DATE'])
      end
    
      def lockfile_name
        "import_entry.lock"
      end
    end
  end
end
