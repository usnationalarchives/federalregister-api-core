class EntryReimporter
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reimport, :retry => 5
  sidekiq_retry_in do |count|
    1
  end
  sidekiq_retries_exhausted do |msg, ex|
    Honeybadger.notify(ex, force: true)
  end

  def perform(date, *args)
    ActiveRecord::Base.clear_active_connections!

    date = date.is_a?(String) ? Date.parse(date) : date

    Content::EntryImporter.process_all_by_date(date, *args)
    GpoImages::DailyIssueImageProcessor.perform(date)
    DailyIssueImageUsageBuilder.new.perform(date)
    Content::TableOfContentsCompiler.perform(date)

    Sidekiq::Client.push(
      'class' => 'IssueReprocessor',
      'args'  => [date.to_s(:iso)],
      'queue' => 'issue_reprocessor'
    )
  end
end
