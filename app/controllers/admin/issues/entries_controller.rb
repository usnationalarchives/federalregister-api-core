class Admin::Issues::EntriesController < AdminController
  skip_before_filter :verify_authenticity_token
  layout 'admin_bootstrap'

  def highlight
    @entry = Entry.find_by_document_number!(params[:id])
    @issue = Issue.last(:order => "publication_date")
    @current_sections = @entry.sections.select do |section|
      section.highlighted_entries(@issue.publication_date).include?(@entry)
    end
  end

  def edit
    @sections = Section.all
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    @entry.curated_title = view_helper.truncate_words(@entry.title, :length => 255) unless @entry[:curated_title].present?
    @entry.curated_abstract = view_helper.truncate_words(@entry.abstract, :length => 500) unless @entry[:curated_abstract].present?
  end
  
  def update
    @sections = Section.all
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    
    if @entry.update_attributes(params[:entry])
      if request.xhr?
        render :nothing => true
      else
        flash[:notice] = 'Successfully saved.'
        if params[:redirect_to]
          redirect_to URI.parse(params[:redirect_to]).path
        else
          redirect_to '/admin'
        end
      end
    else
      flash.now[:error] = 'There was a problem.'
      render :action => :edit
    end
  end
end
