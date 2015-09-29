module Content
  module IssueReprocessorUtils

    def run_cmd(shell_command, error_class, options={})
      errors, stdout = nil, nil
      shell_connection = Open4::popen4(shell_command) do |pid, stdin, stdout, stderr|
        errors = stderr.read.strip
        stdout = stdout.read.strip
      end

      valid_exit_status = options.fetch(:exit_status){0}
      exit = shell_connection.exitstatus
      success = valid_exit_status.is_a?(Array) ? valid_exit_status.include?(exit) : exit == valid_exit_status

      if success
        log("[#{Time.now}] id: #{reprocessed_issue.id} \n Standard Out for '#{shell_command}': #{stdout}")
        return stdout
      else
        Honeybadger.notify(
          :error_class   => error_class,
          :error_message => errors,
          :parameters => {
            :reprocessed_issue_id => reprocessed_issue.id,
            :date => date
          }
        )
        return false
      end
    end

    def mods_path
      File.join(Rails.root,'data','mods')
    end

    def temporary_mods_path
      File.join(Rails.root,'data','mods','tmp')
    end

    def logger
      @logger ||= Logger.new(log_path)
    end

    def log(message)
      logger.info("#{Time.current.to_s(:time_then_date)}: #{message}")
    end

    def log_path
      "#{Rails.root}/log/reprocessor_issue.log"
    end

    def update_status(status)
      reprocessed_issue.update_attributes(:status => status)
    end

    def update_message(text)
      message = reprocessed_issue.message || ""
      message << "\n- #{text}"

      reprocessed_issue.message = message
      reprocessed_issue.save!
    end

  end
end
