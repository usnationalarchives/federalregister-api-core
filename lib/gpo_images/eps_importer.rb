require 'zlib'

class GpoImages::EpsImporter
  SLEEP_DURATION_BETWEEN_SFTP_CHECKS = 5

  attr_reader :filenames_to_download, :temp_images_path, :bucket_name, :sftp_connection,
              :fog_aws_connection, :temp_zip_files_path

  def initialize(options={})
    @sftp_connection ||= options.fetch(:sftp_connection) { GpoImages::Sftp.new }
    @fog_aws_connection ||= options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
    @temp_images_path = GpoImages::FileLocationManager.temp_images_path
    @temp_zip_files_path = GpoImages::FileLocationManager.temp_zip_files_path
    @bucket_name = SETTINGS["zipped_eps_images_s3_bucket"]
  end

  def self.run
    new.process
  end

  def process
    download_eps_images
    create_zip(temp_zip_files_path, "#{md5}.zip")
    upload_zip_and_manifest_to_s3("#{md5}.zip")
    remove_temporary_files
  end

  private

  def download_eps_images
    @filenames_to_download = unchanged_files_list.map(&:first)
    puts "Beginning download of the following files: #{filenames_to_download.to_sentence}"
    FileUtils.makedirs temp_images_path
    begin
    filenames_to_download.each do |filename|
      puts "Downloading #{filename}..."
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
    @md5 ||= Digest::MD5.hexdigest(filenames_to_download.sort.map do |file_name|
      Digest::MD5.file("#{temp_images_path}/#{file_name}")
    end.join)
  end

  def create_zip(path, filename)
    FileUtils.makedirs path
    path_and_filename = File.join(path, filename)

    begin
      Zip::ZipFile.open(path_and_filename, Zip::ZipFile::CREATE) do |zipfile|
        filenames_to_download.each do |filename|
          zipfile.add(filename, File.join(temp_images_path, filename))
        end
      end
      delete_directory_contents(temp_images_path)
    rescue => exception
      delete_directory_contents(temp_images_path)
      delete_directory_contents(temp_zip_files_path)
      #TODO: Include Honeybadger notify.
      raise "A failure occured when building zip file: #{exception.backtrace}: #{exception.message} (#{exception.class})"
    end

  end

  def upload_zip_and_manifest_to_s3(file_name)
    bucket = fog_aws_connection.directories.new(:key => bucket_name)
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{file_name}", #BC TODO: Extract to path manager
      :body   => File.open(File.join(temp_zip_files_path, file_name)),
      :public => false
    )
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{file_name}.manifest.yaml",
      :body   => filenames_to_download.to_yaml,
      :public => false
    )
  end

  def remove_temporary_files
    FileUtils.rm(File.join(temp_zip_files_path, "#{md5}.zip"))
    sftp_connection do |connection|
      filenames_to_download.each do |filename|
        connection.remove(filename)
      end
    end
  end

end
