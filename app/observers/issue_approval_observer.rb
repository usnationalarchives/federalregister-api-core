class IssueApprovalObserver < ActiveRecord::Observer
  include CacheUtils
  observe :issue_approval

  def after_save(issue_approval)
    purge_cache("^/")
    
    Section.all.each do |section|
      purge_cache("^/#{section.slug}")
    end

    purge_cache('^/api/v1')
    purge_cache('^/esi')
  end
end
