require 'spec_helper'

describe Content::IssueReprocessor do
  describe "#rotate_mods_files" do
    include FileIoSpecHelperMethods

    let(:spec_current_mods_path) { File.join('tmp','data','mods') }
    let(:spec_temporary_mods_path) {File.join('tmp','data','mods','tmp') }
    let(:spec_mods_archive_path) {File.join('tmp','data','mods','archive') }

    before(:each) do
      reprocessed_issue = ReprocessedIssue.create
      reprocessed_issue.issue = Issue.create(
        :publication_date => "2099-01-01".to_date
      )
      reprocessed_issue.save
      issue_reprocessor = Content::IssueReprocessor.new(
        reprocessed_issue.id
      )
      issue_reprocessor.stub(:archive_mods_path).and_return(spec_mods_archive_path)
      issue_reprocessor.stub(:mods_path).and_return(spec_current_mods_path)
      issue_reprocessor.stub(:temporary_mods_path).and_return(spec_temporary_mods_path)

      create_file("#{spec_temporary_mods_path}/2099-01-01.xml", "new_mods")
      create_file("#{spec_current_mods_path}/2099-01-01.xml", "current_mods")
      issue_reprocessor.send(:rotate_mods_files)
    end

    after(:each) do
      FileUtils.rm_rf(Dir.glob(File.join(spec_current_mods_path, '*')))
    end

    it "Newly-archived files have the same contents as the existent file." do
      IO.read("#{spec_mods_archive_path}/#{Dir.entries(spec_mods_archive_path).last}").should == "current_mods"
    end

    it "Current mods content should be replaced with the temporary file's contents" do
      IO.read("#{spec_current_mods_path}/2099-01-01.xml").should == "new_mods"
    end
  end
end
