class EpsImporter
  require 'zlib'

  def self.run
    processor = new
    processor.process
  end

  def process
    Net::SFTP.start('ftp.gpo.gov', secrets["gpo"]["username"], :password => secrets["gpo"]["password"]) do |sftp|
      initial_list = filenames_with_sizes(sftp)
      sleep 5
      delayed_list = filenames_with_sizes(sftp)
      files_unchanged = initial_list & delayed_list #BC TODO: Test this logic.
      filenames_to_download = files_unchanged.map{|f|f[0]}

      puts "Beginning download of the following files: #{filenames_to_download.each{|f|puts f}}"
      filenames_to_download.each do |filename|
        puts "Downloading #{filename}..."
        data = sftp.download!(filename, "tmp/tmp_image_files/#{filename}")
      end

      md_5 = create_md5(filenames_to_download, "tmp/tmp_image_files")
      create_zip(md_5, filenames_to_download)
      store_image("#{md_5}.zip")
    end
  end

  private

  def fog_aws_connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => secrets["s3"]["username"],
      :aws_secret_access_key    => secrets["s3"]["password"],
      :endpoint => 'https://s3.amazonaws.com/'
    })
  end

  def secrets
    secrets ||= YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
  end

  def filenames_with_sizes(sftp)
    filenames_with_sizes = []
    sftp.dir.foreach("/") do |entry|
      if entry.attributes.size > 0
        filenames_with_sizes.push([entry.name, entry.attributes.size])
      end
    end
    filenames_with_sizes
  end

  def create_md5(filenames_to_download, filepath)
    Digest::MD5.hexdigest(filenames_to_download.sort.map do |file_name|
      Digest::MD5.file("#{filepath}/#{file_name}")
    end.join)
  end

  def create_zip(archive_name, filenames_to_download)
    folder = "tmp/tmp_image_files"
    zipfile_name = "tmp/#{archive_name}.zip"

    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      filenames_to_download.each do |filename|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, folder + '/' + filename)
      end
    end
  end

  def store_image(file_name)
    bucket_name = 'eps.images.fr2.criticaljuncture.org'
    bucket = fog_aws_connection.directories.new(:key => bucket_name)
    bucket.files.create(
      :key    => "#{Date.current.to_s(:ymd)}/#{file_name}",
      :body   => File.open("tmp/#{file_name}"),
      :public => false
    )
  end

end
