class SectionsController < ApplicationController
  include Shared::SectionsControllerUtilities
  
  def show
    prepare_for_show(params[:slug], Entry.latest_publication_date)
    @preview = false
  end
  
  def about
    @section = Section.find_by_slug(params[:slug])
  end
end