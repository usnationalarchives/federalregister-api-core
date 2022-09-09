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
  end

  FILE_BATCH_SIZE = 25
  def perform
    if filenames_to_download.size > 0
      filenames_to_download.in_groups_of(FILE_BATCH_SIZE, false).each do |file_batch|
        begin
          download_eps_images(file_batch)
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
    end
  end

  private

  attr_reader :fog_aws_connection, :sftp_connection

  def upload_to_s3!(bucket_directory_connection, key, file_path)
    bucket_directory_connection.files.create(
      :key    => key,
      :body   => File.open(File.join(file_path)),
      :public => false
    )
  end

  def bucket_name
    SETTINGS["s3_buckets"]["image_holding_tank"]
  end

  def temp_images_path
    File.join(Rails.root, 'data', 'efs', 'image_pipeline','temp_image_files')
  end

  def filenames_to_download
    @filenames_to_download ||= unchanged_files_list.map(&:first)
  end

  def download_eps_images(filenames)
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

  def unchanged_files_list
    if !Rails.env.test? && SETTINGS['cron']['images']['streamlined_image_pipeline_sftp_path'].blank?
      raise "An SFTP path must be explicitly specified for the streamlined image pipeline"
    end

    initial_list = sftp_connection.filenames_with_sizes(streamlined_image_pipeline_sftp_path, true)
    sleep SLEEP_DURATION_BETWEEN_SFTP_CHECKS
    delayed_list = sftp_connection.filenames_with_sizes(streamlined_image_pipeline_sftp_path, true)
    files_unchanged = initial_list & delayed_list
  end

  def streamlined_image_pipeline_sftp_path
    SETTINGS['cron']['images']['streamlined_image_pipeline_sftp_path']
  end

end
