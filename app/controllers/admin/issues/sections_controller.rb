class Admin::Issues::SectionsController < AdminController
  def show
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:id])
    @highlighted_entries = @section.highlighted_entries(@publication_date)
  end
end