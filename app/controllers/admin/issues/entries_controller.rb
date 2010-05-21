class Admin::Issues::EntriesController < AdminController
  def edit
    @sections = Section.all
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    @entry.curated_title = view_helper.truncate(@entry.title, 255) unless @entry[:curated_title].present?
    @entry.curated_abstract = view_helper.truncate(@entry.abstract, 500) unless @entry[:curated_abstract].present?
  end
  
  def update
    @sections = Section.all
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    
    if @entry.update_attributes(params[:entry])
      flash[:notice] = 'Successfully saved.'
      redirect_to params[:redirect_to]
    else
      flash.now[:error] = 'There was a problem.'
      render :action => :edit
    end
  end
end