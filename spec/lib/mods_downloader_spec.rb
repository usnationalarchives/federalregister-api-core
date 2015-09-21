require 'ruby-debug'
require 'spec_helper'

describe IssueReprocessor::ModsDownloader do

  describe ".create_diff" do
    let(:spec_current_mods_path) { File.join('data','mods') }
    let(:spec_temporary_mods_path) {File.join('data','mods','tmp') }
    let(:spec_mods_archive_path) {File.join('data','mods','archive') }

    after(:each) do
      FileUtils.rm_f('data/mods/2099-01-01.xml')
      FileUtils.rm_f('data/mods/tmp/2099-01-01.xml')
    end

    it ".create_diff returns an empty string if the files are the same" do
      pending("To investigate Circle not finding Open4")
      original_xml = "<XML></XML>"
      modified_xml = "<XML></XML>"
      FileUtils.makedirs(spec_current_mods_path)
      File.open("data/mods/2099-01-01.xml", "w") { |file| file.write(original_xml) }
      FileUtils.makedirs(spec_temporary_mods_path)
      File.open("data/mods/tmp/2099-01-01.xml", "w") { |file| file.write(modified_xml) }

      issue = Issue.create(:publication_date => "2099-01-01".to_date)
      reprocessed_issue = ReprocessedIssue.create
      reprocessed_issue.issue = issue
      reprocessed_issue.save
      mods_downloader = IssueReprocessor::ModsDownloader.new(reprocessed_issue.id)
      mods_downloader.create_diff

      reprocessed_issue.reload.diff.should == ""
    end

    it ".create_diff returns a diff if the files are different" do
      pending("To investigate Circle not finding Open4")
      original_xml = "<XML></XML>"
      modified_xml = "<XML>New Stuff</XML>"
      File.open("data/mods/2099-01-01.xml", "w") { |file| file.write(original_xml) }
      File.open("data/mods/tmp/2099-01-01.xml", "w") { |file| file.write(modified_xml) }
      issue = Issue.create(:publication_date => "2099-01-01".to_date)
      reprocessed_issue = ReprocessedIssue.create
      reprocessed_issue.issue = issue
      reprocessed_issue.save

      mods_downloader = IssueReprocessor::ModsDownloader.new(reprocessed_issue)
      mods_downloader.create_diff
      reprocessed_issue.reload.diff.should be_present
    end
  end

end
