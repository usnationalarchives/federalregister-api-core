class SpecialController < ApplicationController
  def home
    expires_in 4.hours, :public => true
    @sections = Section.all
  end
  
  def agency_highlight
    expires_in 10, :public => true
    @agency_highlight = AgencyHighlight.random_choice
    render :layout => false
  end
end
