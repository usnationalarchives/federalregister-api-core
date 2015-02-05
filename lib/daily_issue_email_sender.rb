class DailyIssueEmailSender
  @queue = :default

  def self.perform(date)
    Mailer.deliver_daily_import_update_admin_email(Date.parse(date))
  end
end
