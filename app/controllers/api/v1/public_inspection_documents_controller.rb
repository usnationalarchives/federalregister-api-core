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
          {order: 'newest', per_page: 200}.merge(deserialized_params),
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

  def public_inspection_search(params, fields=[])
    term = params[:conditions] && params[:conditions][:term].present?
    excerpts = fields.include?(:excerpts)

    PublicInspectionDocumentSearch.new(deserialized_params.merge(excerpts: term && excerpts))
  end

  def facets
    field_facets = %w(type agency agencies)
    raise ActiveRecord::RecordNotFound unless (field_facets).include?(params[:facet])

    search = PublicInspectionDocumentSearch.new(deserialized_params)
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
    search = PublicInspectionDocumentSearch.new(deserialized_params)

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
          render_csv(documents, fields, filename)
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
          document_data(document, fields)
        end
      end
    end
  end

  private

  #NOTE: Thinking Sphinx v3 is much stricter about types and will throw errors if a string value like "1" is passed in lieu of its integer counterpart
  BOOLEAN_PARAMS_NEEDING_DESERIALIZATION = [
    :special_filing
  ]
  def deserialized_params
    params.tap do |modified_params|
      BOOLEAN_PARAMS_NEEDING_DESERIALIZATION.each do |param_name|
        param = modified_params[:conditions].try(:[], param_name)
        if param.present?
          modified_params[:conditions][param_name] = param.to_i
        end
      end
    end
  end

  def document_data(document, fields)
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
                :results => documents.map{|d| document_data(d,fields)},
                :special_filings_updated_at => issue.special_filings_updated_at,
                :regular_filings_updated_at => issue.regular_filings_updated_at
             }
    end
    render_json_or_jsonp data
  end

  def render_csv(documents, fields, filename)
    output = CSV.generate do |csv|
      csv << fields
      documents.each do |result|
        representation = PublicInspectionDocumentApiRepresentation.new(result)
        csv << fields.map do |field|
          if field == :filed_at
            value = representation.value(field).strftime("%m/%d/%Y at %I:%M %p")
          else
            value = [*representation.value(field)].join('; ')

            if field == :document_number
              value = " #{value}"
            else
              value
            end
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
      :feed_url => request.url
    }
  end
end
