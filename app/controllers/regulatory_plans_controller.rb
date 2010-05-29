class RegulatoryPlansController < ApplicationController
  def show
    @regulatory_plan = RegulatoryPlan.find_by_regulation_id_number(params[:regulation_id_number], :order => "issue DESC")
    @entries = @regulatory_plan.entries.paginate(:per_page => 10, :page => params[:page])
  end
  
  def tiny_url
    regulatory_plan = RegulatoryPlan.find_by_regulation_id_number!(params[:regulation_id_number], :order => "issue DESC")
    redirect_to regulatory_plan_path(regulatory_plan), :status=>:moved_permanently
  end
end