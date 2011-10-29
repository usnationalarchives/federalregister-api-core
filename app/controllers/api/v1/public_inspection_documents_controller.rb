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
          render_search(search) do |result|
            basic_public_inspection_document_data(result).merge(
              :json_url         => api_v1_public_inspection_document_url(result.document_number, :format => :json),
              :excerpts         => result.excerpts.raw_text_via_db
            )
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
        render_one_or_more(PublicInspectionDocument, params[:id]) do |document|
          basic_public_inspection_document_data(document)
        end
      end
    end
  end

  private

  def render_date(date)
    issue = PublicInspectionIssue.published.find_by_publication_date(date)
    if issue.nil?
      data = {:count => 0, :results => []}
    else
      documents = issue.public_inspection_documents
      data = {
                :count => documents.size,
                :results => documents.map{|d| basic_public_inspection_document_data(d).merge(
                    :json_url => api_v1_public_inspection_document_url(d.document_number, :format => :json)
                )}
             }
    end
    render_json_or_jsonp data
  end

  def basic_public_inspection_document_data(document)
    {
      :document_number  => document.document_number,
      :publication_date => document.publication_date,
      :filed_at         => document.filed_at,
      :filing_type      => document.special_filing? ? 'special' : 'regular',
      :type             => document.entry_type,
      :html_url         => entry_url(document),
      :pdf_url          => document.pdf.url(:with_banner, false),
      :pdf_file_size    => document.pdf_file_size,
      :pdf_updated_at   => document.pdf_updated_at,
      :num_pages        => document.num_pages,
      :toc_subject      => document.toc_subject,
      :title            => (document.toc_doc || document.title),
      :docket_numbers   => document.docket_numbers.map(&:number),
      :editorial_note   => document.editorial_note,
      :agencies         => document.agency_names.map{|agency_name|
        agency = agency_name.agency
        if agency
          {
            :raw_name  => agency_name.name,
            :name      => agency.name,
            :id        => agency.id,
            :url       => agency_url(agency),
            :json_url  => api_v1_agency_url(agency.id, :format => :json)
          }
        else
          {
            :raw_name  => agency_name.name
          }
        end
      }
    }
  end
end
