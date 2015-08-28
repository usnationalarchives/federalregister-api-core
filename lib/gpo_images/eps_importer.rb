require 'ruby-debug'

class GpoImages::EpsImporter
  SLEEP_DURATION_BETWEEN_SFTP_CHECKS = 5

  require 'zlib'
  attr_reader :filenames_to_download, :temp_images_path, :bucket_name, :sftp_connection,
              :fog_aws_connection

  def initialize(options={})
    @sftp_connection ||= options.fetch(:sftp_connection) { GpoImages::Sftp.new }
    @fog_aws_connection ||= options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
    FileUtils.makedirs "tmp/gpo_images/temp_image_files"
    @temp_images_path = "tmp/gpo_images/temp_image_files"
    @bucket_name = 'eps.images.fr2.criticaljuncture.org.test'
  end

  def self.run
    processor = new
    processor.process
  end

  def process
    download_eps_images
    create_zip('tmp/gpo_images/temp_zip_files', "#{md5}.zip")
    store_image("#{md5}.zip")
    #BC TODO: Investigate why sftp_connection.close is crashing.
    # sftp_connection.close
    remove_temporary_files
  end

  private

  def download_eps_images
    @filenames_to_download = unchanged_files_list.map(&:first)
    puts "Beginning download of the following files: #{filenames_to_download.to_sentence}"
    filenames_to_download.each do |filename|
      puts "Downloading #{filename}..."
      data = sftp_connection.download!(filename, "#{temp_images_path}/#{filename}")
    end
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
    #BC TODO: Implement mkdir_p
    path_and_filename = File.join(path, filename)
    Zip::ZipFile.open(path_and_filename, Zip::ZipFile::CREATE) do |zipfile|
      filenames_to_download.each do |filename|
        zipfile.add(filename, File.join(temp_images_path, filename))
      end
    end
  end

  def store_image(file_name)
    bucket = fog_aws_connection.directories.new(:key => bucket_name)
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{file_name}",
      :body   => File.open("tmp/gpo_images/temp_zip_files/#{file_name}"),
      :public => false
    )
  end

  def remove_temporary_files
    FileUtils.rm(File.join('tmp/gpo_images/temp_zip_files/', "#{md5}.zip"))
    filenames_to_download.each do |filename|
      FileUtils.rm(File.join(temp_images_path, filename))
      # TODO: DO NOT IMPLEMENT UNTIL PRODUCTION READY: sftp_connection.remove(filename)
    end
  end

end
