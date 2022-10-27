# This class downloads files from the SFTP server and stores them in an S3 bucket (the image holding tank) as a way to ensure both STAGING and PROD environments both have access to SFTP images.
class ImagePipeline::SftpDownloader
  SLEEP_DURATION_BETWEEN_SFTP_CHECKS = 5 #seconds

  class SftpDownloadFailure < StandardError; end

  def initialize(options={})
    @sftp_connection    = options.fetch(:sftp_connection) do
      GpoImages::Sftp.new(
        username: Rails.application.secrets[:gpo_historical_images_sftp][:username],
        password: Rails.application.secrets[:gpo_historical_images_sftp][:password]
      ) 
    end
    @fog_aws_connection = options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
    @image_source       = ImageSource.find_by_id!(options.fetch(:image_source_id))
  end

  FILE_BATCH_SIZE = 25
  def perform
    directories.each do |directory_name|
      puts "Processing files in #{directory_name}..."
      puts "===================================================================="
      filenames_to_download = get_unchanged_files_list(directory_name)

      filenames_to_download.in_groups_of(FILE_BATCH_SIZE, false).each do |file_batch|
        sftp_connection.refresh_connection!
        begin
          download_files_locally!(file_batch)
        rescue SftpDownloadFailure => e
          Honeybadger.notify(e)
          next #ie skip batch
        end

        bucket_directory_connection = fog_aws_connection.directories.new(:key => bucket_name)

        begin
          file_batch.each do |filename|
            filename_without_path = File.basename(filename)
            puts "Uploading #{filename_without_path} to S3..."
            upload_to_s3!(
              bucket_directory_connection,
              filename_without_path,
              File.join(temp_images_path, filename_without_path)
            ) 
          end
        rescue StandardError => exception
          raise "A failure occurred when uploading an original image file to S3: #{exception.backtrace}: #{exception.message} (#{exception.class})"
        ensure
          delete_directory_contents(temp_images_path)
        end

        sftp_connection.remove_files_from_sftp_server(file_batch)
      end

      # Clean up directory structure
      if (directory_name != '/') && get_unchanged_files_list(directory_name, sleep_duration: 0).count == 0
        # NOTE: #rmdir! does not delete dir unless empty
        begin
          sftp_connection.rmdir!("#{directory_name}/graphics-submitted")
          sftp_connection.rmdir!(directory_name)
        rescue Net::SFTP::StatusException => error
          if error.code == 3 #  error code 3 is permission denied.  This can sometimes occur if partially-completed files are left behind (eg files prefixed with 'nfs')
            Honeybadger.notify(error)
          else
            raise error
          end
        end
      end

    end
  end

  private

  attr_reader :fog_aws_connection, :image_source, :sftp_connection

  def directories
    if image_source.batch_download_from_sftp_by_subdirectory
      # Handle an SFTP directory structure like: FR-2014-01-01/graphics-submitted/test_image.eps (batch handle directories for performance/fault-tolerance)
      sftp_connection.
        list_directories('/').
        sort.
        select{|date_string| Date.parse(date_string.gsub('FR-', "")) < GpoImages::DailyIssueImageProcessor::GPO_IMAGE_START_DATE }
    else
      # Handle an SFTP directory structure like /test_image.eps
      ['/']
    end
  end

  def upload_to_s3!(bucket_directory_connection, key, file_path)
    bucket_directory_connection.files.create(
      :key    => key,
      :body   => File.open(File.join(file_path)),
      :public => false,
      :tags   => "image_source_id=#{image_source.id}"
    )
  end

  def bucket_name
    SETTINGS["s3_buckets"]["image_holding_tank"]
  end

  def temp_images_path
    File.join(Rails.root, 'data', 'efs', 'image_pipeline','temp_image_files')
  end

  def download_files_locally!(filenames)
    FileUtils.mkdir_p temp_images_path

    begin
      filenames.each do |filename|
        puts "Downloading #{filename}..."
        data = sftp_connection.download!(filename, "#{temp_images_path}/#{File.basename(filename)}")
      end
    rescue StandardError => exception
      #NOTE: sftp_connection#download! sometimes raises a non-specific RuntimeError due to permission denials.  Raise our custom error so we can skip to the next batch of images
      delete_directory_contents(temp_images_path)
      raise SftpDownloadFailure.new("A failure occurred when downloading a file from historical GPO SFTP: #{exception.backtrace}: #{exception.message} (#{exception.class})")
    end
  end

  def delete_directory_contents(directory)
    FileUtils.rm_rf(Dir.glob(File.join(directory, '*')))
  end

  def get_unchanged_files_list(directory, sleep_duration: nil)
    initial_list = sftp_connection.filenames_with_sizes(directory, true, false)
    sleep sleep_duration || SLEEP_DURATION_BETWEEN_SFTP_CHECKS
    delayed_list = sftp_connection.filenames_with_sizes(directory, true, false)
    files_unchanged = initial_list & delayed_list
    files_unchanged.map(&:first)
  end

end
