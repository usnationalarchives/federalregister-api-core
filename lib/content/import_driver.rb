require 'ftools'
module Content
  class ImportDriver
    include HoptoadNotifier::Catcher
  
    def perform
      load "#{Rails.root}/Rakefile"
    
      if today_is_a_holiday?
        puts "Holiday! Exiting."
        exit
      end
    
      if todays_import_is_complete?
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
      rescue Content::EntryImporter::BulkdataFile::DownloadError, Content::EntryImporter::ModsFile::DownloadError
        raise "Unable to download new content"
      rescue Exception => e
        HoptoadNotifier.notify(e)
        raise e
      ensure
        remove_lock_file
      end
    end
  
    def todays_import_is_complete?
      Issue.complete?(Time.local.to_date)
    end
  
    def today_is_a_holiday?
      Holiday.find_by_date(Time.local.to_date)
    end
  
    def lock_file_already_exists?
      File.exists?(lock_file_path)
    end
  
    def create_lock_file
      # create file if it doesn't exist; error out if it does; prevents potential race condition
      File.open(lock_file_path, File::CREAT|File::EXCL|File::RDWR) do |f|
        f.write("#{Process.pid} - #{Time.now}")
      end
    end
  
    def remove_lock_file
      File.delete(lock_file_path)
    end
  
    def clean_up_old_data
      mods_path = Content::EntryImporter::ModsFile.new(Time.local.to_date).path
      bulk_path = Content::EntryImporter::BulkdataFile.new(Time.local.to_date).path
    
      if File.exists?(mods_path) || File.exists?(bulk_path)
        File.makedirs("#{Rails.root}/data/import_issues/#{Time.now}")
      end
    end
  
    private
  
    def lock_file_path
      "#{RAILS_ROOT}/tmp/import.lock"
    end
  end
end