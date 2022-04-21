require 'spec_helper'

describe ImagePipeline::SftpDownloader do
  describe "#unchanged_files_list" do
    it "does not add a file to list if its size changes" do
      sftp_connection = double
      sftp_connection.stub(:filenames_with_sizes).and_return(
        [
          ["test_file_1.eps", 1000],
          ["test_file_2.eps", 1000],
        ],
        [
          ["test_file_1.eps", 1000],
          ["test_file_2.eps", 9000],
        ]
      )
      stub_const("GpoImages::EpsImporter::SLEEP_DURATION_BETWEEN_SFTP_CHECKS", 0)
      described_class.new(:sftp_connection => sftp_connection).
        send(:unchanged_files_list).
        should == [["test_file_1.eps", 1000]]
    end

    it "does not add a file that has appeared during the sleep interval to the list" do
      sftp_connection = double
      sftp_connection.stub(:filenames_with_sizes).and_return(
        [
          ["test_file_1.eps", 1000],
        ],
        [
          ["test_file_1.eps", 1000],
          ["test_file_2.eps", 9000],
        ]
      )
      stub_const("GpoImages::EpsImporter::SLEEP_DURATION_BETWEEN_SFTP_CHECKS", 0)
      described_class.new(:sftp_connection => sftp_connection).
        send(:unchanged_files_list).
        should == [["test_file_1.eps", 1000]]
    end

    it "deletes the downloaded files after uploading to s3"
  end
end
