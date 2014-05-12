class RegulatoryPlansController < ApplicationController
  before_filter :load_regulatory_plan
  
  def show
    cache_for 1.day

    if @regulatory_plan.slug != params[:slug]
      redirect_to regulatory_plan_path(@regulatory_plan), :status => :moved_permanently
    else
      respond_to do |wants|
        wants.html do
          @entry_count = EntrySearch.new(:conditions => {:regulation_id_number => @regulatory_plan.regulation_id_number}).count
        end
      
        wants.rss do
          @feed_name = "Federal Register: Recent documents about RIN #{@regulatory_plan.regulation_id_number}"
          @feed_description = "Federal Register documents about RIN #{@regulatory_plan.regulation_id_number}."
          @entries = EntrySearch.new(:conditions => {:regulation_id_number => @regulatory_plan.regulation_id_number}, :order => "newest", :per_page => 20).results
          render :template => 'entries/index.rss.builder'
        end
      end
    end
  end
  
  def timeline
    cache_for 1.day
    render :layout => false
  end
  
  def tiny_url
    redirect_to regulatory_plan_path(@regulatory_plan), :status=>:moved_permanently
  end
  
  def json_summary
    respond_to do |wants|
      wants.js do
        render :json => {:name => @regulatory_plan.title}
      end
    end
  end
  
  private
  
  def load_regulatory_plan
    @regulatory_plan = RegulatoryPlan.find_by_regulation_id_number!(params[:regulation_id_number], :order => "issue DESC")
  end
end
