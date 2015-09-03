require 'ruby-debug'

class GpoImages::FileConverter
  attr_reader :bucket_name, :bucketed_zip_filename, :date,
              :base_filename, :compressed_image_bundles_path, :fog_aws_connection,
              :uncompressed_eps_images_path

  def initialize(bucketed_zip_filename, date, options={})
    @bucket_name = 'eps.images.fr2.criticaljuncture.org'
    @fog_aws_connection ||= options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
    @bucketed_zip_filename = bucketed_zip_filename
    @base_filename = File.basename(@bucketed_zip_filename)
    @compressed_image_bundles_path = GpoImages::FileLocationManager.compressed_image_bundles_path
    @uncompressed_eps_images_path = GpoImages::FileLocationManager.uncompressed_eps_images_path
    @date = date
    make_temp_directories
  end

  def process
    if !zip_file_exists? #BC TODO: Validate bad .eps files do not blow up
      download_eps_image_bundle
      unzip_file(uncompressed_eps_images_path, File.join(compressed_image_bundles_path, base_filename) )
    end
  end

  private

  def make_temp_directories
    FileUtils.makedirs compressed_image_bundles_path
    FileUtils.makedirs uncompressed_eps_images_path
  end

  def download_eps_image_bundle
    file = fog_aws_connection.
      directories.
      get(bucket_name, :prefix => date.to_s(:ymd)).
      files.
      get(bucketed_zip_filename)
    local_file = File.open(File.join(compressed_image_bundles_path, base_filename), "w")
    local_file.write(file.body)
    local_file.close
  end

  def unzip_file (destination, zip_file)
    Zip::ZipFile.open(zip_file) do |zip_contents|
      FileUtils.makedirs(destination)
      # There are intentionally two zip_file.each blocks to ensure a queue is built
      # before processing on this queue starts.
      zip_contents.each{|file| add_to_redis_set(file.name) if File.extname(file.name) == ".eps"}
      zip_contents.each do |file|
        if File.extname(file.name) == ".eps"
          path_with_file = File.join(destination, file.name)
          zip_contents.extract(file, path_with_file) unless File.exist?(path_with_file)
          Resque.enqueue(GpoImages::BackgroundJob, file.name, bucketed_zip_filename, date)
        end
      end
    end
  end

  def zip_file_exists?
    File.exist? File.join(compressed_image_bundles_path, base_filename)
  end

  def redis_key
    "images_left_to_convert:#{base_filename}"
  end

  def add_to_redis_set(filename)
    Redis.new.sadd(redis_key, filename)
  end

end
