class DailyIssueEmailSender
  @queue = :api_core

  def self.perform(date)
    ActiveRecord::Base.verify_active_connections!
    
    Mailer.deliver_daily_import_update_admin_email(Date.parse(date))
  end
end
