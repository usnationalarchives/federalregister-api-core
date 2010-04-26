class SectionsController < ApplicationController
  def show
    @section = Section.find_by_slug(params[:slug]) or raise ActiveRecord::RecordNotFound
    @publication_date = Entry.latest_publication_date
  end
end