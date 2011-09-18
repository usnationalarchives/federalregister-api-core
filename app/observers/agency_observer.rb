class AgencyObserver < ActiveRecord::Observer
  include CacheUtils
  observe :agency

  cattr_accessor :disabled

  def after_save(agency)
    return if AgencyObserver.disabled

    purge_cache('/agencies')
    purge_cache('/agencies/' + agency.slug)
  end
end
