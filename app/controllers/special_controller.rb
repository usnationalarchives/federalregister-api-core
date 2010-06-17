class SpecialController < ApplicationController
  def home
    @sections = Section.all
  end
  
  def agency_highlight
    @agency_highlight = AgencyHighlight.random_choice
    render :layout => false
  end
end
