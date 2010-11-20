class SearchController < ApplicationController
  before_filter :load_search
  
  def header
    cache_for 1.day
    render :layout => false
  end
  
  def results
    cache_for 1.day
    respond_to do |wants|
      wants.html { render :layout => false }
      wants.js { render :json => {:count => @search.count} }
    end
  end
  
  def facets
    cache_for 1.day
    facets = @search.send(params[:facet] + "_facets").reject(&:on?)
    if params[:all]
      render :partial => "search/facet", :collection => facets, :as => :facet
    else
      render :partial => "search/facets", :locals => {:facets => facets, :name => params[:facet].humanize.capitalize_first}, :layout => false
    end
  end
end