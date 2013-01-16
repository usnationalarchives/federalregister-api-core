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

    granule_class = params[:granule_class]

    subjects_by_id = {}
    headers = []
    if params[:entry][:fr_index_subject].present?
      headers << params[:entry][:fr_index_subject]
    else
      headers << params[:entry][:fr_index_doc]
    end

    headers << params[:old_subject]

    headers.uniq.each do |header|
      id = "#{granule_class}-#{Digest::MD5.hexdigest(header)}"

      grouping = agency_year.grouping_for_document_type_and_header(granule_class, header)

      if grouping
        subjects_by_id[id] = render_to_string(
          :partial => "grouping",
          :locals => {
            :grouping => grouping,
            :granule_class => granule_class
          }
        )
      else
        subjects_by_id[id] = nil
      end
    end

    render :json => subjects_by_id
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
