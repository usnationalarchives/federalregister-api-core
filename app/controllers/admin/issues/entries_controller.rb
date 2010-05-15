class Admin::Issues::EntriesController < AdminController
  def edit
    @sections = Section.all
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    @entry.curated_title = @entry.title unless @entry[:curated_title].present?
    @entry.curated_abstract = @entry.abstract unless @entry[:curated_abstract].present?
  end
  
  def update
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    
    if @entry.update_attributes(params[:entry])
      flash[:notice] = 'Successfully saved.'
      redirect_to params[:redirect_to]
    else
      render :action => :edit
    end
  end
end