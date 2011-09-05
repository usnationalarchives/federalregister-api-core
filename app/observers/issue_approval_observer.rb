class IssueApprovalObserver < ActiveRecord::Observer
  include CacheUtils
  observe :issue_approval

  def after_save(issue_approval)
    purge_cache("^/")
    Section.all.each do |section|
      purge_cache("^/#{section.slug}")
    end
  end
end
