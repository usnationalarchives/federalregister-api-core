class IndexesController < ApplicationController
  def year
    cache_for 1.day
    @fr_index = FrIndexPresenter.new(params[:year])
  end

  def year_agency
    cache_for 1.day
    agency = Agency.find_by_slug!(params[:agency])
    @agency_year = FrIndexPresenter::Agency.new(agency, params[:year])
  end
end
