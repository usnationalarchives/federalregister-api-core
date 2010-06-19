class SpecialController < ApplicationController
  def home
    cache_for 1.day
    @sections = Section.all
  end
  
  def agency_highlight
    cache_for 10.minutes
    @agency_highlight = AgencyHighlight.random_choice
    render :layout => false
  end
end
