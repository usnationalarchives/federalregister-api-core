class Admin::IndexesController < AdminController
  layout 'admin_bootstrap'

  def year
    @years = FrIndexPresenter.available_years
    @fr_index = FrIndexPresenter.new(params[:year])

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
    @agency_year = FrIndexPresenter::AgencyYear.new(agency, params[:year])

    respond_to do |wants|
      wants.html
      wants.pdf do
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
    agency_year = FrIndexPresenter::AgencyYear.new(agency, params[:year])

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
    input = Tempfile.new(['fr_index', '.html']).path

    File.open(input, 'w') do |f|
      f.write render_to_string(options)
    end

    output = Tempfile.new(['fr_index', '.pdf']).path

   `/usr/local/bin/prince #{input} -o #{output}`

    send_file output, :filename => "fr_index.pdf"
  end
end
