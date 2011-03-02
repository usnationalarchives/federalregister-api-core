namespace :mailing_lists do
  desc "Deliver the mailing list content for a given day"
  task :deliver => :environment do
    if ENV['DATE'].present?
      date = Date.parse(ENV['DATE'])
    else
      date = Date.current
    end
    
    MailingList.active.find_each do |mailing_list|
      mailing_list.deliver!(date, :force_delivery => ENV['FORCE_DELIVERY'])
    end
  end
  
  desc "recalculate active subscriptions for this environment"
  task :recalculate_counts => :environment do
    MailingList.connection.execute("UPDATE mailing_lists SET active_subscriptions_count = 0")
    MailingList.connection.execute("UPDATE mailing_lists,
          (
           SELECT mailing_list_id, COUNT(subscriptions.id) AS count
           FROM subscriptions
           WHERE subscriptions.environment = '#{Rails.env}'
             AND subscriptions.confirmed_at IS NOT NULL
             AND subscriptions.unsubscribed_at IS NULL
           GROUP BY subscriptions.mailing_list_id
          ) AS subscription_counts
       SET mailing_lists.active_subscriptions_count = subscription_counts.count
       WHERE mailing_lists.id = subscription_counts.mailing_list_id")
  end
end
