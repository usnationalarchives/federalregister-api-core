module ElasticsearchIndexer

  def self.resync_index_auditing
    EntryChange.delete_all
    entry_change_collection = Entry.
      where(delta: true).
      pluck(:id).
      map{|entry_id| {entry_id: entry_id}}
    EntryChange.insert_all(entry_change_collection)
  end

end
