class FrIndexAgencyStatusObserver < ActiveRecord::Observer
  observe :fr_index_agency_status

  def after_save(fr_index_agency_status)
    Resque.enqueue(
      FrIndexSingleAgencyCompiler,
      {
        year: fr_index_agency_status.year,
        agency_id: fr_index_agency_status.agency_id,
        slug: fr_index_agency_status.agency.slug
      }
    )
  end
end
