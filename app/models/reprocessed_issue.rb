class ReprocessedIssue < ApplicationModel
  belongs_to :issue

  def download_mods
    self.status = "downloading_mods"
    self.save
    Resque.enqueue(IssueReprocessor::ModsDownloader, self.id)
  end

  def reprocess_issue
    self.status = "in_progress"
    self.save
    Resque.enqueue(IssueReprocessor::Reprocessor, self.id)
  end

end
