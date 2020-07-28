require 'spec_helper'

describe Content::GpoModsDownloader do
  let(:issue) { Issue.create(:publication_date => "2099-01-01") }
  let(:reprocessed_issue) { ReprocessedIssue.create(:issue => issue) }
  let(:mods_downloader) { Content::GpoModsDownloader.new }
  before(:each) do
    allow(mods_downloader).to receive(:reprocessed_issue).and_return(reprocessed_issue)
    allow(mods_downloader).to receive(:path_manager).and_return(FileSystemPathManager.new(reprocessed_issue.issue.publication_date))
  end

  describe "#generate_diffs" do
    it "calls #diff and #html_diff" do
      allow_any_instance_of(FrDiff).to receive(:diff).and_return("")
      allow_any_instance_of(FrDiff).to receive(:html_diff).and_return("")

      expect(mods_downloader).to receive(:diff).once.and_call_original
      expect(mods_downloader).to receive(:html_diff).once.and_call_original

      mods_downloader.generate_diffs
    end

    it "saves the results of diff to the reprocessed issue" do
      allow_any_instance_of(Content::GpoModsDownloader).to receive(:diff).and_return('stubbed diff')
      allow_any_instance_of(Content::GpoModsDownloader).to receive(:html_diff).and_return('stubbed html_diff')

      mods_downloader.generate_diffs
      reprocessed_issue.reload

      reprocessed_issue.diff.should == 'stubbed diff'
      reprocessed_issue.html_diff.should == 'stubbed html_diff'
    end

    it "returns false if there is an error" do
      #FrDiff.stubs(:diff).raises(FrDiff::CommandLineError)

      #mods_downloader.generate_diffs.should == false
    end
  end
end
