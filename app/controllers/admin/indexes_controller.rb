class Admin::IndexesController < AdminController
  layout 'admin_bootstrap'

  def year
    @years = FrIndexPresenter.available_years
    options = params.slice(:max_date)
    @fr_index = FrIndexPresenter.new(params[:year], options)
    @end_date = @fr_index.max_date || Issue.last_issue_date_in_year(@fr_index.year)

    respond_to do |wants|
      wants.html
      wants.pdf do
        @agency_years = @fr_index.agencies

        render_pdf(:action => :year)
      end
    end
  end

  def year_agency
    @years = FrIndexPresenter.available_years

    agency = Agency.find_by_slug!(params[:agency])
    year = params[:year].to_i
    @agency_year = FrIndexPresenter::Agency.new(agency, year)

    @last_completed_issue = Entry.scoped(:conditions => "publication_date <= '#{year}-12-31'").maximum(:publication_date)

    respond_to do |wants|
      wants.html
      wants.pdf do
        @end_date = Issue.last_issue_date_in_year(year)
        @agency_years = [@agency_year]
        render_pdf(:action => :year)
      end
    end
  end

  def update_year_agency
    entries = Entry.scoped(:conditions => {:id => params[:entry_ids]})

    Entry.transaction do
      entries.each do |entry|
        entry.update_attributes!(params[:entry])
      end
    end

    agency = Agency.find_by_slug!(params[:agency])
    agency_year = FrIndexPresenter::Agency.new(agency, params[:year])

    agency_year.update_cache

    header = params[:entry][:fr_index_subject].present? ?
      params[:entry][:fr_index_subject] :
      params[:entry][:fr_index_doc]

    grouping = agency_year.grouping_for_document_type_and_header(params[:granule_class], header)

    partial = case grouping
      when FrIndexPresenter::SubjectGrouping
        "subject_grouping"
      when FrIndexPresenter::DocumentGrouping
        "document_grouping"
      end

    render :json => {
      :id_to_remove => grouping.identifier,
      :header => header,
      :element_to_insert => render_to_string(
        :partial => partial,
        :collection => [grouping]
      )
    }
  end

  def mark_complete
    agency = Agency.find_by_slug!(params[:agency])
    status = FrIndexAgencyStatus.find_or_initialize_by_year_and_agency_id(params[:year], agency.id)

    status.last_completed_issue = params[:last_completed_issue]
    status.needs_attention_count = 0
    status.save
    flash[:notice] = "'#{agency.name}' marked complete"
    redirect_to admin_index_year_path(params[:year])
  end

  private

  def render_pdf(options={})
    Tempfile.open(['fr_index', '.pdf']) do |output_pdf|
      output_pdf.close

      Tempfile.open(['fr_index', '.html']) do |input_html|
        input_html.write render_to_string(options)
        input_html.close

        `/usr/local/bin/prince #{input_html.path} -o #{output_pdf.path}`
      end

      send_file output_pdf.path, :filename => "fr_index.pdf"
    end
  end
end
