module EntryReimporter
  @queue = :reimport

  def self.perform(*args)
    Content::EntryImporter.process_all_by_date(*args)
  end
end
