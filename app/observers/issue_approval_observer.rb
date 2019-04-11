class IssueApprovalObserver < ActiveRecord::Observer
  include CacheUtils
  observe :issue_approval

  def after_save(issue_approval)
    purge_cache(".*")
  end
end
