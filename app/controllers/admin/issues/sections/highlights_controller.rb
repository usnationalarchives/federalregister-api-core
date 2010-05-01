class Admin::Issues::Sections::HighlightsController < AdminController
  def create
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:section_id])
    @section_highlight = SectionHighlight.new(params[:section_highlight])
    @section_highlight.section = @section
    @section_highlight.publication_date = @publication_date
    
    @section_highlight.save!
  end
  
  def update
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:section_id])
    @section_highlight = SectionHighlight.find_by_publication_date_and_section_id_and_entry_id!(@publication_date, @section, params[:id])
    
    @section_highlight.update_attributes!(params[:section_highlight])
    render :nothing => true
  end
  
  def destroy
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:section_id])
    @section_highlight = SectionHighlight.find_by_publication_date_and_section_id_and_entry_id!(@publication_date, @section, params[:id])
    @section_highlight.destroy
    render :nothing => true
  end
end