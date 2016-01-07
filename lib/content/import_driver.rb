require 'ftools'
module Content
  class ImportDriver
    class InvalidPid < StandardError; end

    def perform
      exit unless should_run?
    
      if lock_file_already_exists?
        if other_process_is_running?
          if other_process_is_old?
            puts "Lock file exists, but other process (PID #{other_process_pid}) exists and is too old. Killing it now."
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
      rescue Exception => e # capture run failure
        Honeybadger.notify(e)
        raise e
      ensure
        remove_lock_file
      end
    rescue SystemExit => e # don't alert on honeybadger for expected exits
      raise e
    rescue Exception => e # capture import driver perform failure
      Honeybadger.notify(e)
      raise e
    end
  
    def lock_file_already_exists?
      File.exists?(lock_file_path)
    end

    def other_process_pid
      return @other_process_pid if @other_process_pid

      pid = IO.read(lock_file_path).try(:to_i)

      if pid > 0
        @other_process_pid = pid
      else
        puts "Invalid PID in Import Driver :: #{IO.read(lock_file_path)}"
        raise InvalidPid
      end
    end

    def other_process_is_old?
      (Time.current - File.stat(lock_file_path).ctime) > 60.minutes
    end
    
    def other_process_is_running?
      begin
        Process.getpgid( other_process_pid )
        return true
      rescue Errno::ESRCH, InvalidPid
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
      sleep(10)
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
