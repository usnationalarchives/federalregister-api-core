namespace :web do
  desc 'Notify web a new issue is available for html compilation and mailing lists'
  task :notify_of_new_issue => :environment do
    date = Content.parse_dates(ENV['DATE']).first

    begin
      Sidekiq::Client.push(
        'class' => 'NewIssueProcessor',
        'args'  => [date.to_s(:iso)],
        'queue' => 'issue_processor',
        'retry' => 0
      )
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
      Honeybadger.notify(e)
    end
  end

  desc 'Notify web a/an issue(s) has been reprocessed and is need of updating html, etc.'
  task :notify_of_updated_issue => :environment do
    begin
      dates = Content.parse_dates(ENV['DATE'])

      dates.each do |date|
        Sidekiq::Client.push(
          'class' => 'IssueReprocessor',
          'args'  => [date.to_s(:iso)],
          'queue' => 'issue_reprocessor',
          'retry' => 0
        )
      end
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
      Honeybadger.notify(e)
    end
  end
end
