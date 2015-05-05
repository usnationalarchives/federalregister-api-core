class SearchController < ApplicationController
  before_filter :load_search
  before_filter :enforce_maximum_per_page
  
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
          render :json => {:errors => @search.validation_errors, :message => "Invalid parameters"}
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
      @num_facets = params[:num_facets].try(:to_i) || 5
      render :partial => "search/facets", :locals => {:facets => facets, :name => params[:facet].humanize.capitalize_first}, :layout => false
    end
  end
  
  private

  def enforce_maximum_per_page
    params.delete(:maximum_per_page)
  end
end
