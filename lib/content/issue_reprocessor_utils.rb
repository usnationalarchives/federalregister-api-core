module Content
  module IssueReprocessorUtils
    def logger
      @logger ||= Logger.new(log_path)
    end

    def log(message)
      logger.info("#{Time.current.in_time_zone.to_s(:time_then_date)}: #{message}")
    end

    def log_path
      "#{Rails.root}/log/reprocessed_issue.log"
    end

    def update_status(status)
      reprocessed_issue.update_attributes(:status => status)
    end

    def update_message(text)
      if reprocessed_issue.message.present?
        reprocessed_issue.message += "\n #{text}"
      else
        reprocessed_issue.message = text
      end

      reprocessed_issue.save
      reprocessed_issue.reload
    end

  end
end
