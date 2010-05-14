class SectionsController < ApplicationController
  include Shared::SectionsControllerUtilities
  
  def show
    prepare_for_show(params[:slug], Entry.latest_publication_date)
  end
end