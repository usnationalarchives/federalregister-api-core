class ReprocessedIssue < ApplicationModel
  belongs_to :issue

  def download_mods
    self.status = "downloading_mods"
    self.save
    IssueReprocessor::ModsDownloader.new(self.id).perform
  end

  def reprocess_issue
    self.status = "in_progress"
    self.save
    IssueReprocessor::IssueReprocessor.new(self.id).perform
  end

end
