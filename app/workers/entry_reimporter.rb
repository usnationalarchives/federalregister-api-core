module EntryReimporter
  @queue = :reimport

  def self.perform(*args)
    #ENV['FORCE_RELOAD_MODS'] = 1
    #ENV['FORCE_RELOAD_BULKDATA'] = 1 
    Content::EntryImporter.process_all_by_date(*args)
  end
end
