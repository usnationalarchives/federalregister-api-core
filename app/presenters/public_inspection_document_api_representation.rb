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
          :json_url  => api_v1_agency_url(agency.id, :format => :json),
          :slug      => agency.slug
        }
      else
        {
          :raw_name  => agency_name.name
        }
      end
    end
  end
  field(:agency_names, :include => {:agency_names => :agency}) {|e| e.agency_names.compact.map{|a| a.agency.try(:name) || a.name}}
  field(:docket_numbers, :include => :docket_numbers) {|document| document.docket_numbers.map(&:number)}
  field(:document_number)
  field(:filed_at)
  field(:editorial_note)
  field(:excerpts, :select => [:document_file_path]) {|document| document.excerpt}
  field(:filing_type, :select => :special_filing) {|document| document.special_filing ? 'special' : 'regular'}
  field(:html_url, :select => [:publication_date, :filed_at, :document_number, :subject_1, :subject_2, :subject_3]) {|document| public_inspection_document_url(document) }
  field(:json_url, :select => :document_number) {|document| api_v1_public_inspection_document_url(document.document_number, :format => :json) }
  field(:raw_text_url, :select => :document_number) {|document|
    public_inspection_raw_text_url(document)
  }
  field(:num_pages)
  field(:page_views, :select => [:document_number, :filed_at]) do |document|
    start_date = SETTINGS['public_inspection_document_page_view_start_date']

    if document.filed_at && start_date && (document.filed_at.to_date >= start_date)
      {
        count:         PageViewCount.count_for(document.document_number, PageViewType::PUBLIC_INSPECTION_DOCUMENT),
        last_updated:  PageViewCount.last_updated(PageViewType::PUBLIC_INSPECTION_DOCUMENT),
      }
    end
  end
  field(:publication_date)
  field(:last_public_inspection_issue, :select => :public_inspection_issues) do |document|
    issue_dates = document.public_inspection_issues.pluck(:publication_date)
    if issue_dates.present?
      issue_dates.sort.last.to_s(:iso)
    end
  end
  field(:type, :select => :granule_class) {|document| document.entry_type}
  field(:pdf_file_name)
  field(:pdf_file_size)
  field(:pdf_updated_at)
  field(:pdf_url, :select => :pdf_file_name) {|document| document.pdf.url(:with_banner, false)}
  field(:title, :select => [:subject_1, :subject_2, :subject_3]) {|document| document.title}
  field(:toc_doc, :select => [:subject_1, :subject_2, :subject_3]) {|document| document.toc_doc}
  field(:toc_subject, :select => [:subject_1, :subject_2, :subject_3]) {|document| document.toc_subject}
  field(:subject_1)
  field(:subject_2)
  field(:subject_3)

  def self.default_index_fields_csv
    [:agency_names, :document_number, :editorial_note, :filed_at, :filing_type, :json_url, :num_pages, :publication_date, :type]
  end

  def self.default_index_fields_json
    all_fields
  end

  def self.default_index_fields_rss
    [:publication_date, :subject_1, :subject_2, :subject_3, :document_number, :pdf_file_size, :num_pages, :filed_at, :agencies, :editorial_note]
  end

  def self.default_show_fields_json
    all_fields - [:json_url, :excerpts]
  end
end
