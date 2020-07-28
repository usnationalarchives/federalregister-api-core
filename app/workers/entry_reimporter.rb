class EntryReimporter
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reimport, :retry => 0

  def perform(date, *args)
    ActiveRecord::Base.clear_active_connections!

    date = date.is_a?(String) ? Date.parse(date) : date

    Content::EntryImporter.process_all_by_date(date, *args)
    GpoImages::DailyIssueImageProcessor.perform(date)
    Content::TableOfContentsCompiler.perform(date)

    Resque.enqueue_to(
      :issue_reprocessor,
      IssueReprocessor,
      date.to_s(:iso)
    )
  end
end
