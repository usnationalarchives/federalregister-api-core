require 'ftools'
module Content
  class ImportDriver
    def perform
      exit unless should_run?
    
      if lock_file_already_exists?
        if other_process_is_running?
          if other_process_is_old?
            puts "Lock file exists, but other process (PID #{other_process_pid}) exists and isn't too old. Killing it now."
            kill_other_process
          else
            puts "Lock file exists and other process is running and not older than an hour; exiting as another process is working on the import. Exiting."
            exit
          end
        else
          puts "Lock file exists but other process is not running; removing lock file and continuing"
          remove_lock_file
        end
      end
    
      create_lock_file
      begin
        run
      rescue Exception => e
        Honeybadger.notify(e)
        raise e
      ensure
        remove_lock_file
      end
    end
  
    def lock_file_already_exists?
      File.exists?(lock_file_path)
    end

    def other_process_pid
      @other_process_pid ||= IO.read(lock_file_path).try(:to_i)
    end

    def other_process_is_old?
      (Time.current - File.stat(lock_file_path).ctime) > 60.minutes
    end
    
    def other_process_is_running?
      begin
        Process.getpgid( other_process_pid )
        return true
      rescue Errno::ESRCH
        return false
      end
    end
  
    def create_lock_file
      # register callback to cleanup lock file on unexpected exit
      #    ...in theory, this is redundant
      at_exit{ remove_lock_file }
      
      # create file if it doesn't exist; error out if it does; prevents potential race condition
      File.open(lock_file_path, File::CREAT|File::EXCL|File::RDWR) do |f|
        f.write(Process.pid)
      end
    end

    def kill_other_process
      Process.kill("TERM", other_process_pid)
      remove_lock_file
    end
  
    def remove_lock_file
      File.delete(lock_file_path) if File.exists?(lock_file_path)
    end
  
    def should_run?
      true
    end

    private
  
    def lock_file_path
      "#{RAILS_ROOT}/tmp/#{lockfile_name}"
    end
  end
end
