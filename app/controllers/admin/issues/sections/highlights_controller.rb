class Admin::Issues::Sections::HighlightsController < AdminController
  skip_before_action :verify_authenticity_token

  def create
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:section_id])
    @section_highlight = SectionHighlight.new(section_highlight_params)
    @section_highlight.section = @section
    @section_highlight.publication_date = @publication_date
    @section_highlight.save
    move_to_top
    @redirect_to = admin_issue_section_path(@publication_date.to_s(:mdy_dash), @section)

    unless request.xhr?
      redirect_to @redirect_to
    end
  end

  def update
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:section_id])
    @section_highlight = SectionHighlight.find_by_publication_date_and_section_id_and_entry_id!(@publication_date, @section, params[:id])

    if @section_highlight.update_attributes(section_highlight_params)
      respond_to do |wants|
        wants.html do
          redirect_to admin_issue_section_path(@publication_date.to_s(:db), @section)
        end
        wants.js do
          head :ok
        end
      end
    else
      render :action => :edit
    end
  end

  def destroy
    @publication_date = Date.parse(params[:issue_id])
    @section = Section.find_by_slug(params[:section_id])
    @section_highlight = SectionHighlight.find_by_publication_date_and_section_id_and_entry_id!(@publication_date, @section, params[:id])
    @section_highlight.destroy
    head :ok
  end

  private

  def section_highlight_params
    params.require(:section_highlight).permit(
      :entry_id,
      :entry_document_number,
      :new_position
    ).tap do |custom_params|
      if custom_params[:new_position].present?
        custom_params[:new_position] = custom_params[:new_position].to_i
      end
    end
  end

  MAX_DEADLOCK_RETRIES = 3
  def move_to_top
    retry_count = 0
    begin
      @section_highlight.move_to_top
    rescue #Mysql2::Error
      if retry_count < MAX_DEADLOCK_RETRIES
        sleep 1
        retry_count += 1
        retry
      end
    end
  end

end
