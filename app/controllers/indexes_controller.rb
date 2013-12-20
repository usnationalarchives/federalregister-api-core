class IndexesController < ApplicationController
  def year
    cache_for 1.day
    @fr_index = FrIndexPresenter.new(params[:year])
  end

  def year_agency
    cache_for 1.day
    agency = Agency.find_by_slug!(params[:agency])
    @agency_year = FrIndexPresenter::AgencyPresenter.new(agency, params[:year])
  end

  def year_agency_type
    cache_for 1.day
    agency = Agency.find_by_slug!(params[:agency])
    @document_type = FrIndexPresenter::DocumentType.new(agency, params[:year], params[:type])
    render :layout => false
  end
end
