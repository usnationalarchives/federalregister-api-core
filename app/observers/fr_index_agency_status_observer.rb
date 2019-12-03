class FrIndexAgencyStatusObserver < ActiveRecord::Observer
  observe :fr_index_agency_status

  cattr_accessor :disabled

  def after_save(fr_index_agency_status)
    return if FrIndexAgencyStatusObserver.disabled

    Resque.enqueue(
      FrIndexSingleAgencyCompiler,
      {
        year: fr_index_agency_status.year,
        agency_id: fr_index_agency_status.agency_id
      }
    )
  end
end
