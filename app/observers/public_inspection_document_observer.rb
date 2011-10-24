class PublicInspectionDocumentObserver < CacheExpirer
  observe :public_inspection_document

  def after_save(public_inspection_document)
    if public_inspection_document.publication_date
      purge_cache(entry_path(public_inspection_document))
    end
  end
end
