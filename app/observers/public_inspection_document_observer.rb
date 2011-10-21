class PublicInspectionDocumentObserver < CacheExpirer
  observe :public_inspection_document

  def after_save(public_inspection_document)
    purge_cache(entry_path(public_inspection_document))
  end
end
