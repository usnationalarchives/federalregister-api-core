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

      if entry.executive_order?
        purge_cache("^/executive-orders")
        purge_cache("^/esi/layouts/navigation/executive-orders")
        purge_cache("^/esi/home/presidential_documents")
      end
    end
  end
end
