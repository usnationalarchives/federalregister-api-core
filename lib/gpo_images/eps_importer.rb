require 'zlib'

class GpoImages::EpsImporter
  SLEEP_DURATION_BETWEEN_SFTP_CHECKS = 5 #seconds

  attr_reader :fog_aws_connection, :sftp_connection

  def initialize(options={})
    @sftp_connection = options.fetch(:sftp_connection) { GpoImages::Sftp.new }
    @fog_aws_connection = options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
  end

  def self.run
    new.process
  end

  def process
    download_eps_images
    if filenames_to_download.size > 0
      create_zip(temp_zip_files_path, "#{md5}.zip")
      create_manifest("#{md5}.zip")
      upload_zip_and_manifest_to_s3("#{md5}.zip")
      remove_temporary_files
    end
  end

  private

  def bucket_name
    SETTINGS["s3_buckets"]["zipped_eps_images"]
  end

  def temp_zip_files_path
    GpoImages::FileLocationManager.temp_zip_files_path
  end

  def temp_images_path
    GpoImages::FileLocationManager.temp_images_path
  end

  def filenames_to_download
    @filenames_to_download ||= unchanged_files_list.map(&:first)
  end

  def download_eps_images
    puts "Beginning download of the following files: #{filenames_to_download.to_sentence}" if filenames_to_download.present?
    FileUtils.makedirs temp_images_path

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
    initial_list = sftp_connection.filenames_with_sizes
    sleep SLEEP_DURATION_BETWEEN_SFTP_CHECKS
    delayed_list = sftp_connection.filenames_with_sizes
    files_unchanged = initial_list & delayed_list
  end

  def md5
    @md5 ||= Digest::MD5.hexdigest(filenames_to_download.sort.map do |filename|
      Digest::MD5.file("#{temp_images_path}/#{filename}")
    end.join)
  end

  def create_zip(path, filename)
    FileUtils.makedirs path
    zip_file_path = File.join(path, filename)

    begin
      Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
        filenames_to_download.each do |filename|
          zipfile.add(filename, File.join(temp_images_path, filename))
        end
      end
      delete_directory_contents(temp_images_path)
    rescue => exception
      delete_directory_contents(temp_images_path)
      delete_directory_contents(temp_zip_files_path)
      Honeybadger.notify(
        :error_class   => "Failure occurred while unzipping a downloaded eps image",
        :error_message => exception,
        :parameters    => {
          :filename => filename,
          :filenames_to_download => filenames_to_download,
          :zip_file_path => zip_file_path
        }
      )
      raise "A failure occured when building zip file: #{exception.backtrace}: #{exception.message} (#{exception.class})"
    end

  end

  def create_manifest(filename)
    dir = File.join(
      GpoImages::FileLocationManager.eps_image_manifest_path,
      Date.current.to_s(:ymd)
    )
    FileUtils.mkdir_p(dir)
    File.open(File.join(dir, manifest_filename(filename)), 'w') do |f|
      f.write(manifest_contents)
    end
  end

  def manifest_contents
    @manifest_contents ||= filenames_to_download.to_yaml
  end

  def manifest_filename(filename)
    "#{filename}.manifest.yaml"
  end

  def upload_zip_and_manifest_to_s3(filename)
    bucket = fog_aws_connection.directories.new(:key => bucket_name)
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{filename}",
      :body   => File.open(File.join(temp_zip_files_path, filename)),
      :public => false
    )
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{manifest_filename(filename)}",
      :body   => manifest_contents,
      :public => false
    )
  end

  def remove_temporary_files
    FileUtils.rm(File.join(temp_zip_files_path, "#{md5}.zip"))
    sftp_connection.remove_files_from_sftp_server(filenames_to_download)
  end
end
