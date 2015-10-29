class ReprocessedIssue < ApplicationModel
  belongs_to :issue
  belongs_to :user
  delegate :publication_date, :to => :issue

  def download_mods
    self.status = "downloading_mods"
    self.save
    Resque.enqueue(Content::GpoModsDownloader, self.id)
  end

  def reprocess_issue
    self.status = "in_progress"
    self.save
    Resque.enqueue(Content::IssueReprocessor, self.id)
  end

  def display_loading_message?
    ["in_progress", "downloading_mods"].include? self.status
  end

end
