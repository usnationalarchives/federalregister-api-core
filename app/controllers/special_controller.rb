class SpecialController < ApplicationController
  
  def home
    # stuff here
    @entries = Entry.all(:limit => 30)
  end
end
