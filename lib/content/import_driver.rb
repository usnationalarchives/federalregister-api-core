require 'ftools'
module Content
  class ImportDriver
    include HoptoadNotifier::Catcher
  
    def perform
      load "#{Rails.root}/Rakefile"
      
      calculate_date_to_import!
      
      if import_is_complete?
        puts "Import already complete. Exiting."
        exit
      end
    
      if lock_file_already_exists?
        puts "Lock file exists; exiting, assuming another process is working on the import. Exiting."
        exit
      end
    
      create_lock_file
      begin
        Rake::Task["data:daily:full"].invoke
      rescue Content::EntryImporter::ModsFile::DownloadError
        raise "Problem downloading mods file"
      rescue Content::EntryImporter::BulkdataFile::DownloadError
        raise "Problem downloading bulkdata file"
      rescue Exception => e
        HoptoadNotifier.notify(e)
        raise e
      ensure
        remove_lock_file
      end
    end
    
    def calculate_date_to_import!
      ENV['DATE'] = Issue.next_date_to_import.to_s(:iso)
    end
  
    def import_is_complete?
      Issue.complete?(ENV['DATE'])
    end
  
    def lock_file_already_exists?
      File.exists?(lock_file_path)
    end
  
    def create_lock_file
      # register callback to cleanup lock file on unexpected exit
      #    ...in theory, this is redundant
      at_exit{ remove_lock_file }
      
      # create file if it doesn't exist; error out if it does; prevents potential race condition
      File.open(lock_file_path, File::CREAT|File::EXCL|File::RDWR) do |f|
        f.write("#{Process.pid} - #{Time.now}")
      end
    end
  
    def remove_lock_file
      File.delete(lock_file_path)
    end
  
    private
  
    def lock_file_path
      "#{RAILS_ROOT}/tmp/import.lock"
    end
  end
end