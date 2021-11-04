class EsPublicInspectionDocumentSearchResult < EsSearchResult

  def page_views
    start_date = SETTINGS['public_inspection_document_page_view_start_date']

    if filed_at && start_date && (filed_at.to_date >= start_date)
      {
        count:         PageViewCount.count_for(document_number, PageViewType::PUBLIC_INSPECTION_DOCUMENT),
        last_updated:  PageViewCount.last_updated(PageViewType::PUBLIC_INSPECTION_DOCUMENT),
      }
    end
  end
end
