module EntryReimporter
  @queue = :reimport

  def self.perform(*args)
    ActiveRecord::Base.verify_active_connections!
    
    Content::EntryImporter.process_all_by_date(*args)
    date, attributes = *args
    GpoImages::DailyIssueImageProcessor.perform(date)
    Content::TableOfContentsCompiler.perform(date)
    Content::EntryCompiler.perform(date)
  end
end
