class DailyIssueEmailSender
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :api_core

  def perform(date)
    return unless Settings.deliver_daily_import_email
    
    ActiveRecord::Base.clear_active_connections!

    Mailer.daily_import_update_admin_email(Date.parse(date)).deliver_now
  end
end
