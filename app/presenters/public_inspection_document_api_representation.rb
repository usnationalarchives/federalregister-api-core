class PublicInspectionDocumentApiRepresentation < ApiRepresentation
  field(:agencies, :include => {:agency_names => :agency}) do |document|
    document.agency_names.map do |agency_name|
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
    end
  end
  field(:docket_numbers, :include => :docket_numbers) {|document| document.docket_numbers.map(&:number)}
  field(:document_number)
  field(:filed_at)
  field(:editorial_note)
  field(:excerpts) {|document| document.excerpts.raw_text if document.respond_to?(:excerpts) && document.excerpts}
  field(:filing_type, :select => :special_filing) {|document| document.special_filing? ? 'special' : 'regular'}
  field(:html_url, :select => [:publication_date, :filed_at, :document_number, :slug]) {|document| entry_url(document) }
  field(:json_url, :select => :document_number) {|document| api_v1_public_inspection_document_url(document.document_number, :format => :json) }
  field(:raw_text_url, :select => :document_number) {|document|
    public_inspection_raw_text_url(document)
  }
  field(:num_pages)
  field(:publication_date)
  field(:type, :select => :granule_class) {|document| document.entry_type}
  field(:pdf_file_size)
  field(:pdf_updated_at)
  field(:pdf_url, :select => :document_number) {|document| document.pdf.url(:with_banner, false)}
  field(:title)
  field(:toc_doc)
  field(:toc_subject)

  def self.default_index_fields_json
    all_fields
  end

  def self.default_index_fields_rss
    all_fields
  end

  def self.default_show_fields_json
    all_fields - [:json_url, :excerpts]
  end
end
