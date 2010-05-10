class Admin::Issues::SectionsController < AdminController
  def index
    @sections = Section.all
    @publication_date = Date.parse(params[:issue_id])
  end
  
  def show
    @sections = Section.all
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:id])
    @highlighted_entries = @section.highlighted_entries(@publication_date)
  end
end