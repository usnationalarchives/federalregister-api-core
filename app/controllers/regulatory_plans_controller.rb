class RegulatoryPlansController < ApplicationController
  def show
    @regulatory_plan = RegulatoryPlan.find_by_regulation_id_number(params[:regulation_id_number], :order => "issue DESC")
  end
  
  def search
    @search = RegulatoryPlanSearch.new(params)
  end
  
  def search_facet
    @search = RegulatoryPlanSearch.new(params)
    facets = @search.send(params[:facet] + "_facets")
    render :partial => "search/facet", :collection => facets, :layout => nil
  end
  
  def tiny_url
    regulatory_plan = RegulatoryPlan.find_by_regulation_id_number!(params[:regulation_id_number], :order => "issue DESC")
    redirect_to regulatory_plan_path(regulatory_plan), :status=>:moved_permanently
  end
end