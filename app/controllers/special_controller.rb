class SpecialController < ApplicationController
  def home
    expires_in 10.minutes, :public => true
    @sections = Section.all
  end
  
  def agency_highlight
    @agency_highlight = AgencyHighlight.random_choice
    render :layout => false
  end
end
