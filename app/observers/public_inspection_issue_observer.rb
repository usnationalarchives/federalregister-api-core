class PublicInspectionIssueObserver < CacheExpirer
  observe :public_inspection_issue

  def after_save(public_inspection_issue)
    purge_cache(public_inspection_documents_by_date_path(public_inspection_issue.publication_date))
    purge_cache(public_inspection_documents_path)
    purge_cache(api_v1_public_inspection_documents_path + '*')
    agencies = public_inspection_issue.public_inspection_documents.map(&:agencies).flatten.uniq
    agencies.each do |agency|
      purge_cache(agency_path(agency))
    end
  end
end
