class Admin::IndexesController < AdminController
  layout 'admin_bootstrap'

  def year
    @year = params[:year].to_i
#    raise ActiveRecord::RecordNotFound if @year < 2012

    @agencies = FrIndexPresenter.agencies_in_year(@year)
  end

  def year_agency
    @year = params[:year].to_i
#    raise ActiveRecord::RecordNotFound if @year < 2012
    @agency = Agency.find_by_slug!(params[:agency])
    @entries_by_type = FrIndexPresenter.entries_for_year_and_agency_grouped_by_toc_subject(@year, @agency)

    respond_to do |wants|
      wants.html
      wants.pdf do
        input = Tempfile.new(['fr_index', '.html']).path
        File.open(input, 'w') do |f|
          f.write render_to_string
        end

        output = Tempfile.new(['fr_index', '.pdf']).path

       `/usr/local/bin/prince #{input} -o #{output}`

        send_file output, :filename => "fr_index.pdf"
      end
    end
  end

  def update_year_agency
    year = params[:year].to_i
    agency = Agency.find_by_slug!(params[:agency])

    base_scope = FrIndexPresenter.entries_for_year_and_agency(year, agency).
      scoped(:conditions => {:granule_class => params[:type]})

    entries = base_scope.scoped(:conditions => {:id => params[:entry_ids]})

    Entry.transaction do
      entries.each do |entry|
        entry.update_attributes!(params[:entry])
      end
    end

    subjects_by_id = {}
    [params[:entry][:fr_index_subject], params[:old_subject]].uniq.each do |subject|
      subject_entries = base_scope.all(
        :conditions => [
          "fr_index_subject = :subject OR
          (fr_index_subject IS NULL and toc_subject = :subject) OR
          (fr_index_subject IS NULL AND toc_subject IS NULL AND title = :subject)",
          {:subject => subject}
        ]
      )

      entries_by_title = subject_entries.group_by(&:fr_index_doc).sort
      
      id = "#{params[:type]}-#{Digest::MD5.hexdigest(subject)}"

      if subject_entries.present?
        subjects_by_id[id] = render_to_string(
          :partial => "subject_and_children",
          :locals => {
            :subject => subject,
            :entries_by_title => entries_by_title,
            :type => params[:type]
          }
        )
      else
        subjects_by_id[id] = nil
      end
    end

    render :json => subjects_by_id
  end
end
