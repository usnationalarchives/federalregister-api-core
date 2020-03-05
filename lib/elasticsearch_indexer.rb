module ElasticsearchIndexer

  def self.resync_index_auditing
    EntryChange.delete_all
    entry_change_collection = Entry.
      where(delta: true).
      pluck(:id).
      map{|entry_id| {entry_id: entry_id}}
    EntryChange.insert_all(entry_change_collection)
  end

  ES_TEMP_FILE = 'tmp/use_elasticsearch'
  def self.es_enabled?
    File.file?(ES_TEMP_FILE)
  end

  def self.toggle_on
    `touch #{ElasticsearchIndexer::ES_TEMP_FILE}`
  end

  def self.toggle_off
    if ElasticsearchIndexer.es_enabled?
      `rm #{ElasticsearchIndexer::ES_TEMP_FILE}`
    end
  end

  BATCH_SIZE = 500
  def self.reindex_entries
    total_entries     = Entry.count
    entries_completed = 0
    Entry.includes(:entry_regulation_id_numbers, :docket_numbers).find_in_batches(batch_size: BATCH_SIZE) do |entry_batch|
      Entry.bulk_index(entry_batch)
      entries_completed += BATCH_SIZE
      puts "Entry Indexing #{(entries_completed.to_f/total_entries * 100).round(2)}% complete"
    end
  end

  def self.handle_entry_changes
    remove_deleted_entries
    reindex_modified_entries
  end

  def self.remove_deleted_entries
    deleted_entry_ids.each do |entry_id|
      $entry_repository.delete(entry_id)
    end
  end

  def self.reindex_modified_entries
    Entry.where(id: EntryChange.where.not(entry_id: deleted_entry_ids).pluck(:entry_id)).each do |entry|
      $entry_repository.save(entry)
    end
  end

  def self.deleted_entry_ids
    EntryChange.
      joins("LEFT JOIN entries on entry_changes.entry_id = entries.id").
      where("entries.id IS NULL").
      pluck(:entry_id)
  end

end
