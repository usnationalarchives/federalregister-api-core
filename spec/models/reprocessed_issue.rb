require 'spec_helper'

describe ReprocessedIssue do
  describe "#download_mods" do
    it "Enqueues a background job to download mods" do
      reprocessed_issue = ReprocessedIssue.create
      Resque.should_receive(:enqueue).with(IssueReprocessor::ModsDownloader, reprocessed_issue.id)
      reprocessed_issue.download_mods
    end
  end

  describe "#reprocess_issue" do
    it "Enqueus a background job to reprocess an issue" do
      reprocessed_issue = ReprocessedIssue.create
      Resque.should_receive(:enqueue).with(IssueReprocessor::ReprocessorIssue, reprocessed_issue.id)
      reprocessed_issue.reprocess_issue
    end
  end
end
