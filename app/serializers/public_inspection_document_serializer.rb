# Used to serialize pi docs for storing in elasticsearch and creating API results when AR is used in lieu of ES for retrieval
class PublicInspectionDocumentSerializer < ApplicationSerializer
  extend PublicInspectionDocumentApiConfiguration

  attributes :agency_ids,
    :document_number,
    :editorial_note,
    :id,
    :num_pages,
    :pdf_file_name,
    :pdf_file_size,
    :special_filing,
    :subject_1,
    :subject_2,
    :subject_3,
    :title
 
  # NOTE: We still need to support AR-based serialization for agencies
  attribute(:agencies, :include => {:agency_names => :agency}, if: Proc.new { |document, params| params[:active_record_retrieval] }) do |document| 
    document.agency_names.map do |agency_name|
      agency = agency_name.agency
      if agency
        {
          :raw_name  => agency_name.name,
          :name      => agency.name,
          :id        => agency.id,
          :url       => agency_url(agency),
          :json_url  => api_v1_agency_url(agency.id, :format => :json),
          :parent_id => agency.parent_id,
          :slug      => agency.slug
        }
      else
        {
          :raw_name  => agency_name.name
        }
      end
    end
  end

  attribute(:agency_letters, :select => [:publication_date], :include => :pil_agency_letters) do |document|
    if document.publication_date && (Date.current < document.publication_date)
      document.pil_agency_letters.map{|x| {title: x.file_file_name, url: x.file.url} }
    else
      []
    end
  end
  # NOTE: We still need to support AR-based serialization for agency names
  attribute(:agency_names, :include => {:agency_names => :agency}, if: Proc.new { |document, params| params[:active_record_retrieval] }) do |e|
    e.agency_names.compact.map{|a| a.agency.try(:name) || a.name}
  end
  attribute(:docket_numbers, :include => :docket_numbers) do |document|
    document.docket_numbers.map(&:number)
  end

  attribute :excerpts, if: Proc.new { |document, params| params[:active_record_retrieval] } do |document|
    nil
  end

  attribute(:filed_at) do |document, params|
    if params[:active_record_retrieval]
      document.filed_at
    else
      document.filed_at&.utc&.iso8601
    end
  end
  attribute(:filing_type, :select => :special_filing) do |document|
    document.special_filing ? 'special' : 'regular'
  end
  attribute(:html_url, :select => [:publication_date, :filed_at, :document_number, :subject_1, :subject_2, :subject_3]) do |document|
    public_inspection_document_url(document)
  end
  attribute(:json_url, :select => :document_number) do |document|
    api_v1_public_inspection_document_url(document.document_number, :format => :json)
  end
  attribute(:last_public_inspection_issue, :include => :public_inspection_issues) do |document|
    issue_dates = document.public_inspection_issues.pluck(:publication_date)
    if issue_dates.present?
      issue_dates.sort.last.to_s(:iso)
    end
  end

  attribute :page_views, if: Proc.new { |document, params| params[:active_record_retrieval] },
    :select => [:document_number, :filed_at] do |document|
    start_date = SETTINGS['public_inspection_document_page_view_start_date']

    if document.filed_at && start_date && (document.filed_at.to_date >= start_date)
      {
        count:         PageViewCount.count_for(document.document_number, PageViewType::PUBLIC_INSPECTION_DOCUMENT),
        last_updated:  PageViewCount.last_updated(PageViewType::PUBLIC_INSPECTION_DOCUMENT),
      }
    end
  end

  attribute :pdf_updated_at do |document, params|
    if params[:active_record_retrieval]
      document.pdf_updated_at
    else
      document.pdf_updated_at&.utc&.iso8601
    end
  end

  attribute :pdf_url, :select => :pdf_file_name do |document|
    document.pdf.url(:with_banner, false)
  end

  attribute :publication_date  do |document|
    document.publication_date&.to_s(:iso) 
  end

  attribute :public_inspection_document_id do |object|
    object.id
  end

  attribute :type, :select => :granule_class do |object, params|
    if params[:active_record_retrieval]
      object.entry_type
    else
      if object.granule_class == "SUNSHINE"
        "NOTICE"
      else
        object.granule_class
      end
    end
  end

  attribute :docket_id do |object|
    object.docket_numbers.map(&:number)
  end

  attribute :raw_text_updated_at do |document|
    document.raw_text_updated_at&.utc&.iso8601
  end

  attribute :raw_text_url, :select => :document_number do |document|
    public_inspection_raw_text_url(document)
  end

  attribute :title, :select => [:subject_1, :subject_2, :subject_3] do |object|
    [
      object.subject_1,
      object.subject_2,
      object.subject_3
    ].join(" ")
  end

  attribute :toc_doc, :select => [:subject_1, :subject_2, :subject_3]
  attribute :toc_subject, :select => [:subject_1, :subject_2, :subject_3]

  attribute :agency_name_ids do |object|
    object.
      agency_name_ids.
      uniq
  end

  attribute :agency_name_ids do |object|
    object.
      agency_name_ids.
      uniq
  end

  attribute :full_text do |object|
    path = "#{FileSystemPathManager.data_file_path}/public_inspection/raw/#{object.document_file_path}.txt"
    if File.file?(path)
      File.read(path)
    end
  end
end
