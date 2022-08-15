# This class downloads files from the SFTP server and stores them in an S3 bucket (the image holding tank) as a way to ensure both STAGING and PROD environments both have access to SFTP images.
class ImagePipeline::SftpDownloader
  SLEEP_DURATION_BETWEEN_SFTP_CHECKS = 5 #seconds

  def initialize(options={})
    @sftp_connection    = options.fetch(:sftp_connection) { GpoImages::Sftp.new }
    @fog_aws_connection = options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
  end

  def perform
    download_eps_images
    if filenames_to_download.size > 0
      bucket_directory_connection = fog_aws_connection.directories.new(:key => bucket_name)
      begin
        filenames_to_download.each do |filename|
          upload_to_s3!(
            bucket_directory_connection,
            filename,
            File.join(temp_images_path, filename)
          ) 
        end
      rescue => exception
        raise "A failure occurred when uploading an EPS file to S3: #{exception.backtrace}: #{exception.message} (#{exception.class})"
      ensure
        delete_directory_contents(temp_images_path)
      end
      sftp_connection.remove_files_from_sftp_server(filenames_to_download)
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

  def download_eps_images
    puts "Beginning download of the following files: #{filenames_to_download.to_sentence}" if filenames_to_download.present?
    FileUtils.mkdir_p temp_images_path

    begin
      filenames_to_download.each do |filename|
        data = sftp_connection.download!(filename, "#{temp_images_path}/#{filename}")
      end
    rescue => exception
      delete_directory_contents(temp_images_path)
      raise "A failure occurred when downloading eps images from GPO SFTP: #{exception.backtrace}: #{exception.message} (#{exception.class})"
    end
  end

  def delete_directory_contents(directory)
    FileUtils.rm_rf(Dir.glob(File.join(directory, '*')))
  end

  def unchanged_files_list
    if !Rails.env.test? && SETTINGS['cron']['images']['streamlined_image_pipeline_sftp_path'].blank?
      raise "An SFTP path must be explicitly specified for the streamlined image pipeline"
    end

    initial_list = sftp_connection.filenames_with_sizes(streamlined_image_pipeline_sftp_path)
    sleep SLEEP_DURATION_BETWEEN_SFTP_CHECKS
    delayed_list = sftp_connection.filenames_with_sizes(streamlined_image_pipeline_sftp_path)
    files_unchanged = initial_list & delayed_list
  end

  def streamlined_image_pipeline_sftp_path
    SETTINGS['cron']['images']['streamlined_image_pipeline_sftp_path']
  end

  def md5
    @md5 ||= Digest::MD5.hexdigest(filenames_to_download.sort.map do |filename|
      Digest::MD5.file("#{temp_images_path}/#{filename}").to_s + filename
    end.join)
  end

end


