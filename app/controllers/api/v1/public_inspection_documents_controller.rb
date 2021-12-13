class Api::V1::PublicInspectionDocumentsController < ApiController
  def index
    respond_to do |wants|
      cache_for 1.day

      wants.json do
        if params[:conditions].present? && params[:conditions][:available_on]
          publication_date = Date.parse(params[:conditions][:available_on])
          render_date(publication_date)
        else
          fields = specified_fields || PublicInspectionDocumentApiRepresentation.default_index_fields_json
          find_options = PublicInspectionDocumentApiRepresentation.find_options_for(fields)

          search = public_inspection_search(deserialized_params, fields)

          render_search(search, find_options, params[:metadata_only]) do |result|
            document_data(result, fields)
          end
        end
      end

      wants.csv do
        fields = specified_fields || PublicInspectionDocumentApiRepresentation.default_index_fields_csv
        find_options = PublicInspectionDocumentApiRepresentation.find_options_for(fields)

        search = public_inspection_search(
          deserialized_params.merge(order: 'newest', per_page: 200),
          fields
        )

        filename = search.summary.gsub(/\W+/, '_').sub(/_$/,'').downcase
        documents = search.results(find_options)
        render_csv(documents, fields, filename)
      end

      wants.rss do
        fields = PublicInspectionDocumentApiRepresentation.default_index_fields_rss
        find_options = PublicInspectionDocumentApiRepresentation.find_options_for(fields)

        search = public_inspection_search(
          deserialized_params.merge(order: 'newest', per_page: 200),
          fields
        )
        documents = search.results(find_options)
        render_rss(documents, "Federal Register #{search.summary}")
      end
    end
  end


  def facets
    field_facets = %w(type agency agencies)
    raise ActiveRecord::RecordNotFound unless (field_facets).include?(params[:facet])

    search = PublicInspectionDocument.search_klass.new(deserialized_params)
    if search.valid?
        facets = search.send("#{params[:facet]}_facets")

        json = facets.each_with_object(Hash.new) do |facet, hsh|
          hsh[facet.identifier] = {
            :count => facet.count,
            :name => facet.name
          }
        end

      cache_for 1.day
      render_json_or_jsonp(json)
    else
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
    end
  end

  def search_details
    search = PublicInspectionDocument.search_klass.new(deserialized_params)

    if search.valid?
      render_json_or_jsonp(
        :suggestions => {},
        :filters => search_filters(search)
      )
    else
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
    end
  end

  def current
    respond_to do |wants|
      wants.json do
        cache_for 1.day
        publication_date = PublicInspectionIssue.latest_publication_date
        render_date(publication_date)
      end

      wants.csv do
        cache_for 1.day
        publication_date = PublicInspectionIssue.latest_publication_date
        issue = PublicInspectionIssue.published.find_by_publication_date(publication_date)

        if issue.nil?
          render nothing: true, status: 404
        else
          fields = specified_fields || PublicInspectionDocumentApiRepresentation.default_index_fields_csv
          documents = issue.public_inspection_documents

          filename = "public_inspection_documents_on_#{publication_date}"
          render_csv(documents, fields, filename, force_ar_retrieval: true)
        end
      end
    end
  end

  def show
    respond_to do |wants|
      wants.json do
        cache_for 1.day
        fields = specified_fields || PublicInspectionDocumentApiRepresentation.default_show_fields_json
        find_options = PublicInspectionDocumentApiRepresentation.find_options_for(fields + [:document_number])

        render_one_or_more(PublicInspectionDocument, params[:id], find_options) do |document|
          active_record_document_data(document, fields)
        end
      end
    end
  end

  private

  #NOTE: Thinking Sphinx v3 is much stricter about types and will throw errors if a string value like "1" is passed in lieu of its integer counterpart
  BOOLEAN_PARAMS_NEEDING_DESERIALIZATION = [
    :special_filing
  ]
  INTEGER_PARAMS_NEEDING_DESERIALIZATION = [
    'agency_ids',
  ]

  def deserialized_params
    params.tap do |modified_params|
      if modified_params[:conditions].present?
        BOOLEAN_PARAMS_NEEDING_DESERIALIZATION.each do |param_name|
          param = modified_params[:conditions].try(:[], param_name)
          if param.present?
            modified_params[:conditions][param_name] = Array.wrap(param).first.to_i
          end
        end

        INTEGER_PARAMS_NEEDING_DESERIALIZATION.each do |param_name|
          ids = modified_params[:conditions].try(:[], param_name)
          if ids.present?
            modified_params[:conditions][param_name] = Array.wrap(ids).map(&:to_i)
          end
        end
      end

      modified_params.delete(:callback)
    end
  end

  def public_inspection_search(pi_params, fields=[])
    if pi_params[:conditions].present? && pi_params[:conditions][:term]
      term = pi_params[:conditions][:term]
    else
      term = nil
    end
    excerpts = fields.include?(:excerpts)

    PublicInspectionDocument.search_klass.new(pi_params.merge(excerpts: term && excerpts))
  end

  def document_data(document, fields)
    if active_record_based_retrieval?
      active_record_document_data(document, fields)
    else
      allowed_fields = (fields & PublicInspectionDocumentApiRepresentation.all_fields)
      Hash[ allowed_fields.map do |field|
        [field, document.send(field)]
      end]
    end
  end

  def active_record_document_data(document, fields)
    representation = PublicInspectionDocumentApiRepresentation.new(document)
    Hash[ fields.map do |field|
      [field, representation.value(field)]
    end]
  end

  def index_url(options)
    api_v1_public_inspection_documents_url(options)
  end

  def render_date(date)
    issue = PublicInspectionIssue.published.find_by_publication_date(date)
    if issue.nil?
      data = {:count => 0, :results => []}
    else
      fields = specified_fields || PublicInspectionDocumentApiRepresentation.default_index_fields_json
      documents = issue.public_inspection_documents
      data = {
                :count => documents.size,
                :results => documents.map{|d| active_record_document_data(d,fields)},
                :special_filings_updated_at => issue.special_filings_updated_at,
                :regular_filings_updated_at => issue.regular_filings_updated_at
             }
    end
    render_json_or_jsonp data
  end

  def render_csv(documents, fields, filename, force_ar_retrieval: false)
    ar_retrieval = force_ar_retrieval || active_record_based_retrieval?

    output = CSV.generate do |csv|
      csv << fields
      documents.each do |result|
        if ar_retrieval
          representation = PublicInspectionDocumentApiRepresentation.new(result)
        else
          fields = (fields & PublicInspectionDocumentApiRepresentation.all_fields)
        end
  
        csv << fields.map do |field|
          if ar_retrieval
            if field == :filed_at
              value = representation.value(field)&.strftime("%m/%d/%Y at %I:%M %p")
            else
              value = [*representation.value(field)].join('; ')
            end
          else
            if field == :filed_at
              value = result.send(field)
              if value.present?
                value = Time.parse(value).strftime("%m/%d/%Y at %I:%M %p")
              end
            else
              value = [*result.send(field)].join('; ')
            end
          end

          if field == :document_number
            value = " #{value}"
          else
            value
          end
        end
      end
    end

    headers['Content-Disposition'] = "attachment; filename=\"#{filename}.csv\""

    render plain: output
  end

  def render_rss(documents, title)
    render :template => 'public_inspection/index.rss.builder', :locals => {
      :documents => documents,
      :feed_name => title,
      :feed_description => "The documents in this feed originate from FederalRegister.gov which displays an unofficial web version of the daily Federal Register. Public Inspection documents originate from official copies filed at the Office of the Federal Register. For more information, please see https://www.federalregister.gov/reader-aids/using-federalregister-gov/understanding-public-inspection.",
      :feed_url => request.url,
      :feed_publication_date => documents.to_a.reject{|d| d.filed_at.nil? }.max_by{|d| d.filed_at}&.filed_at&.to_time || Time.now
    }
  end
end
