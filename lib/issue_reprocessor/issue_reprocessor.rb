class IssueReprocessor::IssueReprocessor
  include CacheUtils
  attr_reader :reprocessed_issue

  def initialize(reprocessed_issue_id)
    @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
  end

  def perform
    reprocess_issue
    reindex
    clear_cache
    update_status
  end

  def reprocess_issue
    #TODO: Implement rake task.
  end

  def reindex
    Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      stdin.puts "indexer -c config/production.sphinx.conf --rotate entry_delta"
    end
  end

  def clear_cache
    purge_cache('/')
  end

  def update_status
    reprocessed_issue.update_attributes(:status => "complete")
  end

end
