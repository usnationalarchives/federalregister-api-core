class Admin::IndexesController < AdminController
  layout 'admin_bootstrap'

  def year
    @years = FrIndexPresenter.available_years
    options = params.slice(:max_date)

    respond_to do |wants|
      wants.html do
        @fr_index = FrIndexPresenter.new(params[:year], options)
      end

      wants.pdf do
        queue_pdf(
          :year => params[:year],
          :max_date => options[:max_date]
        )
      end
    end
  end

  def year_agency
    @years = FrIndexPresenter.available_years

    agency = Agency.find_by_slug!(params[:agency])
    year = params[:year].to_i

    options = params.slice(:max_date)
    @agency_year = FrIndexPresenter::Agency.new(agency, year, options)

    respond_to do |wants|
      wants.html
      wants.pdf do
        queue_pdf(
          :agency_id => agency.id,
          :year => year,
          :max_date => options[:max_date]
        )
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
    status.save

    agency_year = FrIndexPresenter::Agency.new(agency, params[:year])
    FrIndexAgencyStatus.update_cache(agency_year)

    flash[:notice] = "'#{agency.name}' marked complete through #{status.last_completed_issue}"
    redirect_to admin_index_year_path(params[:year])
  end

  private

  def queue_pdf(parameters={})
    file = GeneratedFile.create(:parameters => parameters)
    Resque.enqueue FrIndexPdfGenerator, file.id
    redirect_to admin_generated_file_path(file)
  end
end
