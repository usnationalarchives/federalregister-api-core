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
      stub_const("GpoImages::EpsImporter::SLEEP_DURATION_BETWEEN_SFTP_CHECKS", 0)
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
      stub_const("GpoImages::EpsImporter::SLEEP_DURATION_BETWEEN_SFTP_CHECKS", 0)
      GpoImages::EpsImporter.new(:sftp_connection => sftp_connection).
        send(:unchanged_files_list).
        should == [["test_file_1.eps", 1000]]
    end

  end
end

describe GpoImages::ImagePackage do

  after :each do
    $redis.flushdb
  end

  it ".already_converted? checks whether the redis set has a single entry" do
  end

  it ".already_converted? return false for a new image package" do
    image_package = GpoImages::ImagePackage.new(Date.current, "e99a18c428cb38d5f260853678922e03")
    image_package.already_converted?.should == false
  end

  it ".already_converted? should return true if an image package has been marked as completed" do
    image_package = GpoImages::ImagePackage.new(Date.current, "e99a18c428cb38d5f260853678922e03")
    image_package.mark_as_complete!
    image_package.already_converted?.should == true
  end

  it "can accumulate members in the Redis set" do
    image_package_1 = GpoImages::ImagePackage.new(Date.current, "e99a18c428cb38d5f260853678922e03")
    image_package_1.mark_as_complete!
    image_package_2 = GpoImages::ImagePackage.new(Date.current, "7694f4a66316e53c8cdd9d9954bd611d")
    image_package_2.mark_as_complete!
    $redis.smembers("converted_image_packages:#{Date.current.to_s(:ymd)}").size.should == 2
  end

  it ".mark gracefully fails if the redis set is already empty" do
    image_package = GpoImages::ImagePackage.new(Date.current, "e99a18c428cb38d5f260853678922e03")
    image_package.mark_as_complete!
    image_package.mark_as_complete!
    image_package.already_converted?.should == true
  end
end

describe GpoImages::Sftp do
end

describe GpoImages::FileImporter do
end

describe GpoImages::FileConverter do
end

describe GpoImages::BackgroundJob do
end
