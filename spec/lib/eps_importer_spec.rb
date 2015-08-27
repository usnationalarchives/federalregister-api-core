require 'spec_helper'

describe GpoImages::EpsImporter do
  describe "#unchanged_files_list" do
    it "does not add a file to list if its size changes" do
      sftp_connection = double
      #BC TODO: Stub sleep constant with 0 seconds
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
      GpoImages::EpsImporter.new(:sftp_connection => sftp_connection).
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
      GpoImages::EpsImporter.new(:sftp_connection => sftp_connection).
        send(:unchanged_files_list).
        should == [["test_file_1.eps", 1000]]
    end

    it "deletes the downloaded files after uploading to s3"
  end
end

describe GpoImages::ImagePackage do
  it ".already_converted? checks whether the redis set has a single entry" do
  end
  it "checks whether a file has been converted based on the redis_set"
end

describe GpoImages::Sftp do
end

describe GpoImages::FileImporter do
  it "does not create a FileConverter instance if an image package has already been processed."
end

describe GpoImages::FileConverter do
  it "queues background jobs for eps files"
  it "does not queue background jobs for non-eps files"
end

describe GpoImages::BackgroundJob do
  it "it deletes the local eps file once it has been uploaded to s3"
  it "if the image package's redis set is empty, it adds the image package to the Redis key"
  it "it deletes the local eps file once it has been uploaded to s3"
  it "Adds a gpo_graphic for each local file"
end
