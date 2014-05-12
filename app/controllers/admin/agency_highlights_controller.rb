class Admin::AgencyHighlightsController < AdminController
  def index
    @agency_highlights = AgencyHighlight.all
  end
  
  def new
    if entry.agency_highlight.present?
      flash[:error] = 'This document has already been agency highlighted. You are now editing.'
      redirect_to edit_admin_agency_highlight_path(entry.agency_highlight)
      return
    end
    
    @agency_highlight          = AgencyHighlight.new(:entry => entry)
    @agency_highlight.title    = entry.title
    @agency_highlight.abstract = entry.abstract
    @agency_highlight.highlight_until = entry.comments_close_on || 1.month.from_now
  end
  
  def create
    @agency_highlight = AgencyHighlight.new(params[:agency_highlight])
    
    if @agency_highlight.save
      flash[:notice] = "Agency highlight created."
      redirect_to admin_agency_highlights_path
    else
      flash.now[:error] = "There was a problem!"
      render :action => :new
    end
  end
  
  def edit
    @agency_highlight = AgencyHighlight.find(params[:id])
  end
  
  def update
    @agency_highlight = AgencyHighlight.find(params[:id])
    
    if @agency_highlight.update_attributes(params[:agency_highlight])
      flash[:notice] = "Agency highlight updated."
      redirect_to admin_agency_highlights_path
    else
      flash.now[:error] = "There was a problem!"
      render :action => :edit
    end
  end
  
  def destroy
  end
  
  private
  
  def entry
    @entry ||= Entry.find_by_document_number(params[:document_number])
  end
end
