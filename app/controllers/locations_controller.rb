class LocationsController < ApplicationController
  def edit
    @location = Location.new
  end
end