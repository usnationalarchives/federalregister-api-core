class CannedSearchesController < ApplicationController
  def show
    @canned_search = CannedSearch.find_by_slug!(params[:slug])
  end
end
