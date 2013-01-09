class IndexesController < ApplicationController
  def year
    @year = params[:year].to_i
    @agencies_grouped_by_first_letter = FrIndexPresenter.agencies_in_year(@year).group_by{|a| a.name.chars.first}
  end

  def year_agency
    @year = params[:year].to_i
    @agency = Agency.find_by_slug!(params[:agency])
    @entries_by_toc_subject = FrIndexPresenter.entries_for_year_and_agency_grouped_by_toc_subject(@year, @agency)
    @entries_by_granule_class = FrIndexPresenter.entries_for_year_and_agency_grouped_by_granule_class(@year, @agency)
  end
end
