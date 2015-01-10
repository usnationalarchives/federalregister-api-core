class Api::V1::PublicInspectionDocumentsController < ApiController
  def index
    respond_to do |wants|
      wants.json do 
        cache_for 1.day
        if params[:conditions] && params[:conditions][:available_on]
          publication_date = Date.parse(params[:conditions][:available_on])
          render_date(publication_date)
        else
          search = PublicInspectionDocumentSearch.new(params)
          fields = specified_fields || PublicInspectionDocumentApiRepresentation.default_index_fields_json
          render_search(search, {}, params[:metadata_only]) do |result|
            document_data(result, fields)
          end 
        end
      end
    end
  end

  def current
    respond_to do |wants|
      wants.json do 
        cache_for 1.day
        publication_date = PublicInspectionIssue.latest_publication_date
        render_date(publication_date)
      end
    end  
  end

  def show
    respond_to do |wants|
      wants.json do
        cache_for 1.day
        fields = specified_fields || PublicInspectionDocumentApiRepresentation.default_show_fields_json
        render_one_or_more(PublicInspectionDocument, params[:id]) do |document|
          document_data(document, fields)
        end
      end
    end
  end

  private

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
end
