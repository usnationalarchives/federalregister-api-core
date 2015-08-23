class GpoImages::EpsImporter
  require 'zlib'
  attr_reader :filenames_to_download, :temp_images_path

  def initialize
    @temp_images_path = "tmp/tmp_image_files"
  end

  def self.run
    processor = new
    processor.process
  end

  def process
    download_eps_images
    create_zip md5(temp_images_path)
    store_image("#{md5(temp_images_path)}.zip")
  end

  private

  def secrets
    secrets ||= YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
  end

  def download_eps_images
    Net::SFTP.start(
        'ftp.gpo.gov',
        secrets["gpo"]["username"],
        :password => secrets["gpo"]["password"]
      ) do |sftp_connection|
      @filenames_to_download = unchanged_files_list(sftp_connection).map{|f|f[0]}
      puts "Beginning download of the following files: #{filenames_to_download.to_sentence}"
      filenames_to_download.each do |filename|
        puts "Downloading #{filename}..."
        data = sftp_connection.download!(filename, "#{temp_images_path}/#{filename}")
      end
    end
  end

  def unchanged_files_list(sftp_connection)
    initial_list = filenames_with_sizes(sftp_connection)
    sleep 5
    delayed_list = filenames_with_sizes(sftp_connection)
    files_unchanged = initial_list & delayed_list #BC TODO: Test this logic.
  end

  def filenames_with_sizes(sftp_connection)
    filenames_with_sizes = []
    sftp_connection.dir.foreach("/") do |entry|
      if entry.attributes.size > 0
        filenames_with_sizes.push([entry.name, entry.attributes.size])
      end
    end
    filenames_with_sizes
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
        zipfile.add(filename, temp_images_path + '/' + filename)
      end
    end
  end

  def store_image(file_name)
    bucket_name = 'eps.images.fr2.criticaljuncture.org.test'
    bucket = fog_aws_connection.directories.new(:key => bucket_name)
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{file_name}",
      :body   => File.open("tmp/#{file_name}"),
      :public => false
    )
  end

  def remove_downloaded_files(sftp_connection)
    filenames_to_download.each do |filename|
      sftp_connection.remove(filename)
    end
  end

end
