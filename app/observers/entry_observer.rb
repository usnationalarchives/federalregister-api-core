class EntryObserver < ActiveRecord::Observer
  include CacheUtils
  observe :entry

  cattr_accessor :disabled

  def after_save(entry)
    return if EntryObserver.disabled

    if entry.issue.try(:complete?)
      purge_cache("^/documents/#{entry.publication_date.strftime('%Y')}/#{entry.publication_date.strftime('%m')}/#{entry.publication_date.strftime('%d')}/#{entry.document_number}/*")
      purge_cache("^/api/v1/documents")
      purge_cache("^/esi/document")

      if entry.presidential_document?
        purge_cache("^/presidential-documents")
        purge_cache("^/esi/layouts/navigation/presidential-documents")
      end
    elsif entry.historical_era_eo?
      purge_cache("^/executive-order/#{entry.presidential_document_number}")
      purge_cache("^/presidential-documents/executive-orders/*")
    end
  end

end
