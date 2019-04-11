require 'spec_helper'

describe Content::IssueReprocessor do
  describe "#rotate_mods_files" do
    include FileIoSpecHelperMethods

    let(:path_manager) { FileSystemPathManager.new( Date.parse('2099-01-01') ) }
    let(:archive_time) { Time.now.to_i }

    before(:each) do
      reprocessed_issue = Factory.create(:reprocessed_issue)
      issue_reprocessor = Content::IssueReprocessor.new(reprocessed_issue.id)

      create_file(path_manager.document_temporary_mods_path, "new_mods")
      create_file(path_manager.document_mods_path, "current_mods")
      issue_reprocessor.send(:rotate_mods_files)
    end

    after(:each) do
      delete_file(path_manager.document_mods_path)
      delete_file(path_manager.document_temporary_mods_path)
      delete_file(path_manager.document_archive_mods_path(archive_time))
    end

    it "Newly-archived files have the same contents as the original file." do
      IO.read(path_manager.document_archive_mods_path(archive_time)).should == "current_mods"
    end

    it "Current mods content should be replaced with the temporary file's contents" do
      IO.read(path_manager.document_mods_path).should == "new_mods"
    end
  end
end
