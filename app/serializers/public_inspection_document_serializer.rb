class PublicInspectionDocumentSerializer < ApplicationSerializer
  attributes :agency_ids,
    :document_number,
    :editorial_note,
    :id,
    :num_pages,
    :pdf_file_name,
    :pdf_file_size,
    :pdf_updated_at,
    :special_filing,
    :subject_1,
    :subject_2,
    :subject_3,
    :title,
    :toc_doc,
    :toc_subject

  attribute(:agencies) do |document|
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
  attribute(:agency_letters) do |document|
    if document.publication_date && (Date.current < document.publication_date)
      document.pil_agency_letters.map{|x| {title: x.file_file_name, url: x.file.url} }
    end
  end
  attribute(:agency_names) do |e|
    e.agency_names.compact.map{|a| a.agency.try(:name) || a.name}
  end
  attribute(:docket_numbers) do |document|
    document.docket_numbers.map(&:number)
  end
  attribute(:filed_at) do |document|
    document.filed_at&.utc&.iso8601
  end
  attribute(:filing_type) do |document|
    document.special_filing ? 'special' : 'regular'
  end
  attribute(:html_url) do |document|
    public_inspection_document_url(document)
  end
  attribute(:json_url) do |document|
    api_v1_public_inspection_document_url(document.document_number, :format => :json)
  end
  attribute(:last_public_inspection_issue) do |document|
    issue_dates = document.public_inspection_issues.pluck(:publication_date)
    if issue_dates.present?
      issue_dates.sort.last.to_s(:iso)
    end
  end
  attribute :pdf_url do |document|
    document.pdf.url(:with_banner, false)
  end

  attribute :publication_date  do |document|
    document.publication_date&.to_s(:iso) 
  end

  attribute :public_inspection_document_id do |object|
    object.id
  end

  attribute :type do |object|
    if object.granule_class == "SUNSHINE"
      "NOTICE"
    else
      object.granule_class
    end
  end

  attribute :docket_id do |object|
    object.docket_numbers.map(&:number)
  end

  attribute :raw_text_updated_at do |document|
    document.raw_text_updated_at&.utc&.iso8601
  end

  attribute :raw_text_url do |document|
    public_inspection_raw_text_url(document)
  end

  attribute :title do |object|
    [
      object.subject_1,
      object.subject_2,
      object.subject_3
    ].join(" ")
  end

  attribute :agency_ids do |object|
    object.agency_assignments.map(&:agency_id)
  end

  attribute :full_text do |object|
    path = "#{FileSystemPathManager.data_file_path}/public_inspection/raw/#{object.document_file_path}.txt"
    if File.file?(path)
      File.read(path)
    end
  end
end
