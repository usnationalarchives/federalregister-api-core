class EntryObserver < ActiveRecord::Observer
  include CacheUtils
  observe :entry

  cattr_accessor :disabled

  def after_save(entry)
    return if EntryObserver.disabled

    if entry.issue.try(:complete?)
      purge_cache("^/articles/#{entry.publication_date.strftime('%Y')}/#{entry.publication_date.strftime('%m')}/#{entry.publication_date.strftime('%d')}/#{entry.document_number}/*")
    end
  end
end
