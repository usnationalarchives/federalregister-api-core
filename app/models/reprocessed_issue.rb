class ReprocessedIssue < ApplicationModel
  belongs_to :issue
  belongs_to :user
  delegate :publication_date, :to => :issue

  def download_mods(async: true)
    self.status = "downloading_mods"
    self.save
    if async
      Sidekiq::Client.enqueue(Content::GpoModsDownloader, self.id)
    else
      Content::GpoModsDownloader.new.perform(self.id)
    end
  end

  def reprocess_issue(force_reload_bulkdata = false)
    self.status = "in_progress"
    self.save
    if force_reload_bulkdata
      Sidekiq::Client.enqueue_to(
        queue,
        Content::IssueReprocessor,
        self.id,
        true
      )
    else
      Sidekiq::Client.enqueue_to(
        queue,
        Content::IssueReprocessor,
        self.id
      )
    end
  end

  def display_loading_message?
    ["in_progress", "downloading_mods"].include? self.status
  end

  private

  def queue
    if publication_date == Date.current
      'high_priority'
    else
      'reimport'
    end
  end

end
