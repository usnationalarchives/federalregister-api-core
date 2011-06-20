class AgencyObserver < ActiveRecord::Observer
  include CacheUtils
  observe :agency

  def after_save(agency)
    purge_cache('/agencies')
    purge_cache('/agencies/' + agency.slug)
  end
end
