class AgencyNameObserver < ActiveRecord::Observer
  include CacheUtils
  observe :agency_name

  def after_save(agency_name)
    if (agency_name.agency_id_was)
      agency = Agency.find_by_id(agency_name.agency_id_was)
      purge_cache('/agencies/' + agency.slug) if agency
    end

    if agency_name.agency_id.present?
      purge_cache('/agencies/' + agency_name.agency.slug)
    end
  end
end
