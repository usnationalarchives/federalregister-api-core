class SpecialController < ApplicationController
  def home
    cache_for 1.day
    @sections = Section.all
    @issue = Issue.current
  end
  
  def agency_highlight
    cache_for 10.minutes
    @agency_highlight = AgencyHighlight.random_choice
    if @agency_highlight.present?
      render :layout => false
    else
      render :nothing => true
    end
  end
  
  def popular_entries
    cache_for 1.hour
    @entries = Entry.popular.limit(5)
    
    render :template => "special/popular", :layout => false
  end
  
  def status
    raise "not available"
    current_time_on_database = Entry.connection.select_values("SELECT NOW()").first
    render :text => "Current time is: #{current_time_on_database}"
  end
end
