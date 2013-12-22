class Admin::IndexesController < AdminController
  layout 'admin_bootstrap'
  before_filter :disable_all_browser_caching
  include ActionView::Helpers::TagHelper
  include SpellingHelper

  def year
    @years = FrIndexPresenter.available_years
    @max_date = Date.parse(params[:max_date]) if params[:max_date].present?

    respond_to do |wants|
      wants.html do
        @fr_index = FrIndexPresenter.new(params[:year], :max_date => @max_date)
      end

      wants.pdf do
        queue_preview_pdf(
          :year => params[:year],
          :max_date => params[:max_date]
        )
      end
    end
  end

  def publish
    year = params[:year]
    max_date = params[:max_date]
    fr_index = FrIndexPresenter.new(year, :max_date => max_date)

    Resque.enqueue FrIndexPdfPublisher, {:year => year, :max_date => max_date}
    fr_index.agencies.each do |year_agency|
      Resque.enqueue FrIndexPdfPublisher, {:year => year, :max_date => max_date, :agency_id => year_agency.agency.id}
    end

    flash[:notice] = "#{Date.parse(max_date).to_s(:month_year)} has been queued to be published."
    redirect_to admin_index_year_path(params[:year], :max_date => params[:max_date])
  end

  def year_agency
    @years = FrIndexPresenter.available_years

    agency = Agency.find_by_slug!(params[:agency])
    year = params[:year].to_i

    options = params.slice(:max_date)
    @agency_year = FrIndexPresenter::AgencyPresenter.new(agency, year, options)
    @last_approved_date = last_approved_date

    respond_to do |wants|
      wants.html
      wants.pdf do
        queue_preview_pdf(
          :agency_id => agency.id,
          :year => year,
          :max_date => options[:max_date]
        )
      end
    end
  end

  def year_agency_type
    options = params.slice(:max_date, :unapproved_only)
    agency = Agency.find_by_slug!(params[:agency])

    @document_type = FrIndexPresenter::DocumentType.new(agency, params[:year].to_i, params[:type], options)
    render :layout => false
  end

  def year_agency_unapproved_documents
    @years = FrIndexPresenter.available_years

    agency = Agency.find_by_slug!(params[:agency])
    year = params[:year].to_i

    @agency_year = FrIndexPresenter::AgencyPresenter.new(agency, year, :unapproved_only => true)
    @last_approved_date = last_approved_date
  end

  def update_year_agency
    entries = Entry.scoped(:conditions => {:id => params[:entry_ids]})

    subject = params[:entry][:fr_index_subject]
    doc = params[:entry][:fr_index_doc]

    if doc == '' && subject.present?
      doc = subject
      subject = ''
    end

    Entry.transaction do
      entries.each do |entry|
        entry.update_attributes!(params[:entry].merge(:fr_index_subject => subject, :fr_index_doc => doc))
      end
    end

    agency = Agency.find_by_slug!(params[:agency])
    document_type = FrIndexPresenter::DocumentType.new(agency, params[:year], params[:granule_class], params.slice(:max_date, :unapproved_only))
    document_type.agency_year.update_cache

    header = subject.present? ? subject : doc

    grouping = document_type.grouping_for_header(header)

    partial = case grouping
      when FrIndexPresenter::SubjectGrouping
        "subject_grouping"
      when FrIndexPresenter::DocumentGrouping
        "document_grouping"
      end

    spelling_checker do |spell_checker|
      render :json => {
        :id_to_remove => grouping.identifier,
        :header => header,
        :element_to_insert => render_to_string(
          :partial => partial,
          :collection => [grouping],
          :locals => {:agency_year => document_type.agency_year, :spell_checker => spell_checker}
        )
      }
    end
  end

  def mark_complete
    agency = Agency.find_by_slug!(params[:agency])
    status = FrIndexAgencyStatus.find_or_initialize_by_year_and_agency_id(params[:year], agency.id)
    status.last_completed_issue = params[:last_completed_issue]
    status.save

    agency_year = FrIndexPresenter::AgencyPresenter.new(agency, params[:year])
    FrIndexAgencyStatus.update_cache(agency_year)

    flash[:notice] = "'#{agency.name}' marked complete through #{status.last_completed_issue}"
    redirect_to admin_index_year_path(params[:year], :max_date => params[:max_date])
  end

  private

  def disable_all_browser_caching
    headers['Cache-Control'] = "no-cache, max-age=0, must-revalidate, no-store"
  end

  def queue_preview_pdf(parameters={})
    file = GeneratedFile.create(:parameters => parameters)
    Resque.enqueue FrIndexPdfPreviewer, file.id
    redirect_to admin_generated_file_path(file)
  end

  def last_approved_date
    if @agency_year.last_completed_issue
      @agency_year.last_completed_issue.strftime("%b. #{@agency_year.last_completed_issue.day.ordinalize}")
    else
      ""
    end
  end
end
