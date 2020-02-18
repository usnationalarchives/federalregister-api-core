class DailyIssueEmailSender
  @queue = :api_core

  def self.perform(date)
    ActiveRecord::Base.clear_active_connections!

    Mailer.daily_import_update_admin_email(Date.parse(date)).deliver_now
  end
end
