class SearchController < ApplicationController
  before_filter :load_search
  
  def show
    respond_to do |wants|
      wants.html
      wants.rss do
        @feed_name = "Federal Register: Search Results"
        @feed_description = "Federal Register: Search Results"
        @entries = @search.results
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def header
    render :layout => false
  end
  
  def results
    render :layout => false
  end
  
  def facets
    facets = @search.send(params[:facet] + "_facets")
    render :partial => "search/facets", :locals => {:facets => facets, :name => params[:facet].capitalize_first}, :layout => false
  end
end