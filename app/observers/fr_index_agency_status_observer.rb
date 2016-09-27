class FrIndexAgencyStatusObserver < ActiveRecord::Observer
  include CacheUtils
  observer :fr_index_agency_status

  def after_save(fr_index_agency_status)
    FrIndexAgencyCompiler.process_agency_with_docs(
      fr_index_agency_status.year,
      fr_index_agency_status.agency_id
    )

    purge_cache("/index/#{year}/#{fr_index_agency_status.agency.slug}")
  end
