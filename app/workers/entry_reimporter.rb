module EntryReimporter
  @queue = :reimport

  def self.perform(*args)
    Content::EntryImporter.process_all_by_date(*args)
    date, attributes = *args
    GpoImages::DailyIssueImageProcessor.perform(date)
    XmlTableOfContentsTransformer.perform(date)
    Content::EntryCompiler.perform(date)
  end
end
