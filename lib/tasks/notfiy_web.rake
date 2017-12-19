namespace :web do
  desc 'Notify web a new issue is available for html compilation and mailing lists'
  task :notify_of_new_issue => :environment do
    begin
      Resque.enqueue_to(:issue_processor, 'IssueProcessor', ENV['DATE'])
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
        Resque.enqueue_to(:issue_reprocessor, 'IssueReprocessor', date.to_s(:iso))
      end
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
      Honeybadger.notify(e)
    end
  end
end
