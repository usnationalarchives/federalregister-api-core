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

        Content.run_myfr2_command "bundle exec rake mailing_lists:articles:deliver[\"#{date.to_s(:iso)}\"]"
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
        Resque.enqueue(DailyIssueEmailSender, ENV['DATE'])
      rescue StandardError => e
        puts e.message
        puts e.backtrace.join("\n")
        Honeybadger.notify(e)
      end
    end
  end
end
