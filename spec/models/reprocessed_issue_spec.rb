require 'spec_helper'

describe ReprocessedIssue do
  describe "#download_mods" do
    it "Enqueues a background job to download mods" do
      reprocessed_issue = ReprocessedIssue.create
      Sidekiq::Client.should_receive(:enqueue).with(Content::GpoModsDownloader, reprocessed_issue.id)
      reprocessed_issue.download_mods
    end
  end

  describe "#reprocess_issue" do
    it "Enqueues a background job to reprocess an issue" do
      reprocessed_issue = ReprocessedIssue.create(issue: create(:issue))
      Sidekiq::Client.should_receive(:enqueue_to).with('reimport', Content::IssueReprocessor, reprocessed_issue.id)
      reprocessed_issue.reprocess_issue
    end

    it "Enqueues a high-priority job to reprocess the current day's issue" do
      reprocessed_issue = ReprocessedIssue.create(issue: create(:issue, publication_date: Date.current))
      Sidekiq::Client.should_receive(:enqueue_to).with('high_priority', Content::IssueReprocessor, reprocessed_issue.id)
      reprocessed_issue.reprocess_issue
    end
  end
end
