module PublicInspectionDocumentApiConfiguration

  def api_fields
    [
      :agencies,
      :agency_letters,
      :agency_names,
      :docket_numbers,
      :document_number,
      :editorial_note,
      :excerpts,
      :filed_at,
      :filing_type,
      :html_url,
      :json_url, 
      :last_public_inspection_issue,
      :num_pages,
      :page_views,
      :pdf_file_name,
      :pdf_file_size,
      :pdf_updated_at,
      :pdf_url,
      :publication_date,
      :raw_text_url,
      :subject_1,
      :subject_2,
      :subject_3,
      :title,
      :toc_doc,
      :toc_subject,
      :type,
    ]
  end

  def default_index_fields_csv
    [:agency_names, :document_number, :editorial_note, :filed_at, :filing_type, :json_url, :num_pages, :publication_date, :type]
  end

  def default_index_fields_json
    api_fields
  end

  def default_index_fields_rss
    [:publication_date, :subject_1, :subject_2, :subject_3, :document_number, :pdf_file_size, :num_pages, :filed_at, :agencies, :editorial_note]
  end

  def default_show_fields_json
    api_fields - [:json_url, :excerpts]
  end

end
