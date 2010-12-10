class SearchController < ApplicationController
  before_filter :load_search
  
  def header
    cache_for 1.day
    render :layout => false
  end
  
  def results
    cache_for 1.day
    respond_to do |wants|
      wants.html do
        render :layout => false
      end
      wants.js do
        if @search.valid?
          render :json => {:count => @search.count, :message => render_to_string(:partial => "result_summary.txt.erb")}
        else
          render :json => {:errors => @search.errors, :message => "Invalid parameters"}
        end
      end
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