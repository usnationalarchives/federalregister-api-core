module EntryReimporter
  @queue = :reimport

  def self.perform(*args)
    ActiveRecord::Base.clear_active_connections!

    Content::EntryImporter.process_all_by_date(*args)
    date, attributes = *args
    GpoImages::DailyIssueImageProcessor.perform(date)
    Content::TableOfContentsCompiler.perform(date)

    Resque.enqueue_to(:issue_reprocessor, 'IssueReprocessor', date.to_s(:iso))
  end
end
