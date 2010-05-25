class SectionsController < ApplicationController
  include Shared::SectionsControllerUtilities
  
  def show
    prepare_for_show(params[:slug], Entry.latest_publication_date)
    @preview = false
    respond_to do |wants|
      wants.html do
        render :action => :show
      end
      
      wants.rss do
        @feed_name = "Federal Register: #{@section.title} Section"
        @feed_description = "Highlighted Federal Register entries from #{@section.title} Section."
        @entries = @highlighted_entries
        render :template => 'entries/index.rss.builder'
      end
      
    end
  end
  
  def about
    @section = Section.find_by_slug(params[:slug])
  end
end