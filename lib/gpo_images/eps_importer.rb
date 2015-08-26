require 'ruby-debug'

class GpoImages::EpsImporter
  SLEEP_DURATION_BETWEEN_SFTP_CHECKS = 5.seconds

  require 'zlib'
  attr_reader :filenames_to_download, :temp_images_path, :bucket_name

  def initialize(options)
    @sftp_connection ||= options.fetch(:sftp_connection) { GpoImages::Sftp.new }

    FileUtils.makedirs "tmp/gpo_images/temp_image_files"
    @temp_images_path = "tmp/gpo_images/temp_image_files"
    @bucket_name = 'eps.images.fr2.criticaljuncture.org.test'
  end

  def self.run
    processor = new
    processor.process
  end

  def process
    # download_eps_images
    @filenames_to_download = ["test_image_1.eps", "test_image_2.eps", "test_image_3.eps",]
    create_zip md5(temp_images_path)
    store_image("#{md5(temp_images_path)}.zip")
    sftp_connection.close
    #BC TODO: Enable removal of downloaded images for production.
  end

  private

  def secrets
    secrets ||= YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
  end

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
    files_unchanged = initial_list & delayed_list #BC TODO: Test this logic.
  end

  def fog_aws_connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => secrets["s3"]["username"],
      :aws_secret_access_key    => secrets["s3"]["password"],
      :endpoint => 'https://s3.amazonaws.com/'
    })
  end

  def md5(path_to_files)
    Digest::MD5.hexdigest(filenames_to_download.sort.map do |file_name|
      Digest::MD5.file("#{path_to_files}/#{file_name}")
    end.join)
  end

  def create_zip(archive_name)
    zipfile_name = "tmp/#{archive_name}.zip"
    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      filenames_to_download.each do |filename|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, File.join(temp_images_path, filename))
      end
    end
  end

  def store_image(file_name)
    bucket = fog_aws_connection.directories.new(:key => bucket_name)
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{file_name}",
      :body   => File.open("tmp/#{file_name}"),
      :public => false
    )
  end

  def remove_downloaded_files
    # BC TODO: Remove manually downloaded files in temp_images_path
    filenames_to_download.each do |filename|
      sftp_connection.remove(filename)
    end
  end

end
