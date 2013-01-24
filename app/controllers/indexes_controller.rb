class IndexesController < ApplicationController
  def year
    @fr_index = FrIndexPresenter.new(params[:year])
  end

  def year_agency
    agency = Agency.find_by_slug!(params[:agency])
    @agency_year = FrIndexPresenter::Agency.new(agency, params[:year])
  end
end
