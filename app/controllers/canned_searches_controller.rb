class CannedSearchesController < ApplicationController
  def show
    cache_for 1.day
    @canned_search = CannedSearch.find_by_slug!(params[:slug])
  end
end
