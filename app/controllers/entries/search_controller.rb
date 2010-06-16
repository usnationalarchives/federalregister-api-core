class Entries::SearchController < ApplicationController
  before_filter :load_search
  
  def show
  end
  
  def header
    render :layout => false
  end
  
  def results
    render :partial => "facets", :collection => facets, :layout => false
  end
  
  def facets
    facets = @search.send(params[:facet] + "_facets")
    render :partial => "facets", :collection => facets, :layout => false
  end
  
  private
  
  def load_search
    @search ||= EntrySearch.new(params)
  end
end