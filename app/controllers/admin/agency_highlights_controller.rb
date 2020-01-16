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
    @agency_highlight = AgencyHighlight.new(agency_highlight_params)

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

    if @agency_highlight.update_attributes(agency_highlight_params)
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

  def agency_highlight_params
    params.require(:agency_highlight).permit(
      :section_header,
      :title,
      :abstract,
      :agency_id,
      :published,
      #TODO: Revisit date rendering--do we need a datepicker?
      :"highlight_until(1i)",
      :"highlight_until(2i)",
      :"highlight_until(3i)",
      :entry_id
    )
  end
end
