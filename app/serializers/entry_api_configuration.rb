module EntryApiConfiguration

  def api_fields
    [
      :abstract,
      :action,
      :agencies,
      :agency_names,
      :body_html_url,
      :cfr_references,
      :citation,
      :comment_url,
      :comments_close_on,
      :correction_of,
      :corrections,
      :dates,
      :disposition_notes,
      :docket_id,
      :docket_ids,
      :dockets,
      :document_number,
      :effective_on,
      :end_page,
      :excerpts,
      :executive_order_notes,
      :executive_order_number,
      :full_text_xml_url,
      :html_url,
      :images,
      :images_metadata,
      :json_url,
      :mods_url,
      :not_received_for_publication,
      :page_length,
      :page_views,
      :pdf_url,
      :president,
      :presidential_document_number,
      :proclamation_number,
      :public_inspection_pdf_url,
      :publication_date,
      :raw_text_url,
      :regulation_id_number_info,
      :regulation_id_numbers,
      :regulations_dot_gov_info,
      :regulations_dot_gov_url,
      :significant,
      :signing_date,
      :start_page,
      :subtype,
      :title,
      :toc_doc,
      :toc_subject,
      :topics,
      :type,
      :volume,
    ]
  end

  def default_index_fields_json
    [:title, :type, :abstract, :document_number, :html_url, :pdf_url, :public_inspection_pdf_url, :publication_date, :agencies, :excerpts]
  end

  def default_index_fields_csv
    [:title, :type, :agency_names, :abstract, :citation, :document_number, :html_url, :pdf_url, :publication_date]
  end

  def default_index_fields_rss
    [:title, :abstract, :document_number, :publication_date, :agencies, :topics, :html_url]
  end

  def default_show_fields_json
    api_fields - [:excerpts, :agency_names, :docket_id, :president]
  end

  def default_show_fields_csv
    api_fields - [:excerpts, :agency_names, :docket_id, :president]
  end

end
