class CannedSearchObserver < ActiveRecord::Observer
  include CacheUtils
  observe :canned_search

  def after_save(canned_search)
    purge_cache('/' + canned_search.slug)
    purge_cache('/' + canned_search.section.slug)
  end
end
