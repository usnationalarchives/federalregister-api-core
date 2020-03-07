module ElasticsearchIndexer

  def self.resync_index_auditing
    EntryChange.delete_all
    entry_change_collection = Entry.
      where(delta: true).
      pluck(:id).
      map{|entry_id| {entry_id: entry_id}}
    EntryChange.insert_all(entry_change_collection)
  end

  ES_TEMP_FILE = "tmp/use_elasticsearch_#{Rails.env}"
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
    Entry.includes(:agency_assignments, :citations, :comments_close_date, :docket_numbers, :effective_date, :entry_regulation_id_numbers, :entry_cfr_references, :place_determinations, :section_assignments, :topic_assignments).find_in_batches(batch_size: BATCH_SIZE) do |entry_batch|
      Entry.bulk_index(entry_batch, refresh: false)
      entries_completed += BATCH_SIZE
      puts "Entry Indexing #{(entries_completed.to_f/total_entries * 100).round(2)}% complete"
    end

    $entry_repository.refresh_index!
  end

  def self.reindex_pi_documents
    $public_inspection_document_repository.create_index!(force: true)
    PublicInspectionDocument.bulk_index(
      PublicInspectionDocument.indexable.includes(:agency_assignments, :docket_numbers),
      refresh: false
    )
    $public_inspection_document_repository.refresh_index!
  end

  def self.handle_entry_changes
    remove_deleted_entries
    reindex_modified_entries
    #NOTE: Once ES is deployed and Sphinx is removed, we may want to consider removing the delta flag from the entries in question after reindexing
  end

  def self.remove_deleted_entries
    deleted_entry_ids.each do |entry_id|
      $entry_repository.delete(entry_id, refresh: false)
    end

    $entry_repository.refresh_index!
  end

  def self.reindex_modified_entries
    Entry.
      where(id: EntryChange.where.not(entry_id: deleted_entry_ids).pluck(:entry_id)).
      find_in_batches(batch_size: BATCH_SIZE) do |entry_batch|
        Entry.bulk_index(entry_batch, refresh: false)
      end

    $entry_repository.refresh_index!
  end

  def self.deleted_entry_ids
    EntryChange.
      joins("LEFT JOIN entries on entry_changes.entry_id = entries.id").
      where("entries.id IS NULL").
      pluck(:entry_id)
  end

end
