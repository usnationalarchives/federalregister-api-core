class SpecialController < ApplicationController
  def home
    cache_for 1.day
    @sections = Section.all
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
end
