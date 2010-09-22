class EntryObserver < ActiveRecord::Observer
  include CacheUtils
  observe :entry

  def after_save(entry)
    if entry.issue.try(:complete?)
      purge_cache("^/articles/#{entry.publication_date.strftime('%Y')}/#{entry.publication_date.strftime('%m')}/#{entry.publication_date.strftime('%d')}/#{entry.document_number}/*")
    end
  end
end