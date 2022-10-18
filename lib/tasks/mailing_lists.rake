namespace :mailing_lists do
  namespace :entries do
    desc "Deliver the entry mailing list content for a given day"
    task :deliver => :environment do
      begin
        if ENV['DATE'].present?
          date = Date.parse(ENV['DATE'])
        else
          date = Date.current
        end

        Sidekiq::Client.push(
          'class' => 'DocumentSubscriptionQueuePopulator',
          'args'  => [date.to_s(:iso)],
          'queue' => 'subscriptions',
          'retry' => 0
        )
      rescue StandardError => e
        puts e.message
        puts e.backtrace.join("\n")
        Honeybadger.notify(e)
      end
    end
  end

  namespace :daily_import_email do
    desc "Deliver the daily import email to admins for a given day"
    task :deliver => :environment do  
      begin
        if ENV['DATE'].present?
          date = Date.parse(ENV['DATE'])
        else
          date = Date.current
        end

        Sidekiq::Client.enqueue(DailyIssueEmailSender, date.to_s(:iso))
      rescue StandardError => e
        puts e.message
        puts e.backtrace.join("\n")
        Honeybadger.notify(e)
      end
    end
  end
end
