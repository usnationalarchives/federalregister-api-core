class CannedSearchObserver < ActiveRecord::Observer
  include CacheUtils
  observe :canned_search

  def after_save(canned_search)
    purge_cache('/' + canned_search.slug)
    purge_cache('/' + canned_search.section.slug)

    purge_cache('^/api/v1/suggested_searches')
    
    purge_cache('^/esi/layouts/navigation/sections')
    purge_cache('^/esi/home/sections')
  end
end
