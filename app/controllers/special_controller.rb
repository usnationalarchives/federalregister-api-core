class SpecialController < ApplicationController
  
  def home
    # stuff here
    @entries = Entry.all(:limit => 30)
    @featured_agencies = Agency.featured
  end
end
