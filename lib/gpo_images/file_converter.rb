require 'ruby-debug'

class GpoImages::FileConverter
  attr_reader :bucket_name, :bucketed_zip_filename, :date,
              :processed_images_bucket_name, :base_filename,
              :compressed_image_bundles_path

  def initialize(bucketed_zip_filename, date)
    @bucket_name = 'eps.images.fr2.criticaljuncture.org.test'
    @bucketed_zip_filename = bucketed_zip_filename
    @base_filename = File.basename(@bucketed_zip_filename)
    @compressed_image_bundles_path = "tmp/gpo_images/compressed_image_bundles"
    @date = date
    make_temp_directories
  end

  def make_temp_directories
    FileUtils.makedirs "tmp/gpo_images/compressed_image_bundles"
    FileUtils.makedirs "tmp/gpo_images/uncompressed_eps_images"
  end

  def process
    if !zip_file_exists?
      download_eps_image_bundle
      unzip_file("tmp/gpo_images/uncompressed_eps_images/", "tmp/gpo_images/compressed_image_bundles/#{base_filename}")
    end
  end

  def download_eps_image_bundle
    file = fog_aws_connection.
      directories.
      get(bucket_name, :prefix => date.to_s(:ymd)).
      files.get(bucketed_zip_filename)
    local_file = File.open("tmp/gpo_images/compressed_image_bundles/#{base_filename}", "w")
    local_file.write(file.body)
    local_file.close
  end

  def unzip_file (destination, file)
    Zip::ZipFile.open(file) do |zip_file|
      zip_file.each{|file| add_to_redis_set(file.name)}
      zip_file.each do |f|
        f_path=File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
        Resque.enqueue(GpoImages::BackgroundJob, f.name, bucketed_zip_filename, date)
      end
    end
  end

  private

  def zip_file_exists?
    File.exist? File.join(compressed_image_bundles_path, base_filename)
  end

  def secrets
    secrets ||= YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
  end

  def redis_key
    "converted_files:#{base_filename}"
  end

  def add_to_redis_set(filename)
    Redis.new.sadd(redis_key, filename)
  end

  def fog_aws_connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => secrets["s3"]["username"],
      :aws_secret_access_key    => secrets["s3"]["password"],
      :endpoint => 'https://s3.amazonaws.com/'
    })
  end

end
