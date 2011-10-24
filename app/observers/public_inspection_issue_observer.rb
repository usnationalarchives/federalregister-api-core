class PublicInspectionIssueObserver < CacheExpirer
  observe :public_inspection_issue

  def after_save(public_inspection_issue)
    purge_cache(public_inspection_documents_by_date_path(public_inspection_issue.publication_date))
    purge_cache(public_inspection_documents_path)
  end
end
