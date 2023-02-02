class RegulationsDotGov::RecentlyModifiedDocumentUpdater
  extend Memoist
  include CacheUtils
  
  class MissingDocumentNumber < StandardError; end
  class NoDocumentFound < StandardError; end

  attr_reader :days
  
  def initialize(days)
    @days = days
  end

  def perform
    ActiveRecord::Base.clear_active_connections!
    EntryObserver.disabled = true
    current_time           = Time.current

    updated_documents.each do |updated_document|
      if updated_document.federal_register_document_number.nil?
        notify_missing_document_number(updated_document)
        next 
      end
      
      entry = Entry.find_by_document_number(updated_document.federal_register_document_number)

      if entry
        if entry.comment_url_override.present? && entry.comment_url_override != updated_document.comment_url #NOTE: This is an abort clause that prevents the docket from being set to a different docket in the case where an FR document number is associated with multiple regulations.gov document ids/docket numbers.
          next
        end
        entry.regulations_dot_gov_docket_id = updated_document.docket_id
        if updated_document.comment_start_date
          begin
            entry.comment_count                   = updated_document.comment_count
          rescue RegulationsDotGov::V4::Client::NotFoundError => e
            Honeybadger.notify("Unable to retrieve comment count for #{entry.document_number}")
          end
        end
        entry.regulations_dot_gov_document_id = updated_document.regulations_dot_gov_document_id

        update_docket = entry.regulations_dot_gov_docket_id_changed? && entry.regulations_dot_gov_docket_id.present?

        if updated_document.document_id
          entry.comment_url = updated_document.open_for_comment? ? updated_document.comment_url : nil
          entry.regulationsdotgov_url = updated_document.url
        end

        has_entry_change = entry.changed?

        entry.checked_regulationsdotgov_at = current_time

        entry.save(validate: false)

        if has_entry_change
          purge_cache("^/api/v1/documents/#{entry.document_number}")
          purge_cache("^/documents/#{entry.publication_date.to_s(:ymd)}/#{entry.document_number}")
        end

        if update_docket
          Sidekiq::Client.enqueue(DocketImporter, entry.regulations_dot_gov_docket_id)
        end
      else
        notify_missing_document(updated_document)
      end
    end

    reindex_updated_documents
  end

  private

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/reg_gov_modifed_documents.log")
  end

  def reindex_updated_documents
    Entry.
      pre_joined_for_es_indexing.
      where(document_number: updated_documents.map(&:federal_register_document_number)).
      find_in_batches(batch_size: ElasticsearchIndexer::BATCH_SIZE) do |entry_batch|
        Entry.bulk_index(entry_batch, refresh: false)
      end
  end

  def notify_missing_document(document)
    message = "Regulations Dot Gov returned document #{document.federal_register_document_number} as changed within the last #{days} days, but no document was found.  Document details: #{document.raw_attributes}"
    logger.warn("[NoDocumentFound] #{message}")
  end

  def notify_missing_document_number(document)
    message = "Regulations Dot Gov returned document without a federal_register_document_number as changed within the last #{days} days.  Document details: #{document.raw_attributes}"
    logger.warn("[MissingDocumentNumber] #{message}")
  end

  def updated_documents
    regulations_dot_gov_client.
      find_documents_updated_within(days, document_type_identifiers.join(","))
  end
  memoize :updated_documents

  def document_type_identifiers
    ['Proposed Rule', 'Rule', 'Notice']
  end

  def regulations_dot_gov_client
    RegulationsDotGov::V4::Client.new
  end

end
