class Content::PublicInspectionImporter::DocumentImporter
  attr_reader :pil_importer, :api_doc

  def initialize(pil_importer, api_doc)
    @pil_importer = pil_importer
    @api_doc = api_doc
  end

  def perform
    return unless ready_to_import?

    persist_attributes

    if document.new_record?
      pil_importer.imported_document_numbers << document.document_number
    end

    document.save!

    # Note that we only save the pdf_url to the database in the background
    #   job, and only when the PDF download, watermark, and upload
    #   to S3 has been successful.
    if api_doc.pdf_url? && api_doc.pdf_url != document.pdf_url
      pil_importer.enqueue_job(document.document_number, api_doc.pdf_url)
    end
  end

  def ready_to_import?
    if api_doc.update_pil_at.nil?
      if api_doc.filed_at.nil?
        true
      else
        pil_importer.start_time >= api_doc.filed_at
      end
    else
      pil_importer.start_time >= api_doc.update_pil_at
    end
  end

  private

  def document
    @document ||= PublicInspectionDocument.find_or_initialize_by_document_number(api_doc.document_number)
  end

  def persist_attributes
    assign_basic_attributes
    assign_agencies
    assign_category
    assign_extra_info
  end

  def assign_basic_attributes
    %w(subject_1 subject_2 subject_3 filed_at publication_date editorial_note).each do |attr|
      document.send("#{attr}=", api_doc.send(attr))
    end

    unless document.public_inspection_issues.include?(pil_importer.issue)
      document.public_inspection_issues << pil_importer.issue
    end
  end

  def assign_agencies
    document.agency_names = api_doc.agency_names.map{|name| AgencyName.find_or_create_by_name(name)}
    document.agency_ids = document.agency_names.map(&:agency_id)
  end

  def assign_category
    document.granule_class = case api_doc.category
      when 'RULES'
        'RULE'
      when 'NOTICES'
        'NOTICE'
      when 'PROPOSED RULES'
        'PRORULE'
      when 'EXECUTIVE ORDERS', 'PROCLAMATIONS', 'ADMINISTRATIVE ORDERS'
        'PRESDOCU'
      else
        # TODO: notify us
        'UNKNOWN'
      end

    if api_doc.category.present?
      document.category = api_doc.category.downcase.capitalize_most_words
    else
      # TODO: notify us
      document.category = 'Unknown'
    end

    document.special_filing = api_doc.filing_section == 'Special'
    document.update_pil_at = api_doc.update_pil_at || api_doc.filed_at
  end
 
  def assign_extra_info
    # TODO: killed documents
    # TODO: CFR
    # TODO: only create new docket number records when needed
    document.docket_numbers = api_doc.docket_numbers.map{|number| DocketNumber.new(:number => number)}
  end
end
