class GpoImages::FileConverter
  attr_reader :bucketed_zip_filename,
    :date,
    :fog_aws_connection

  IMAGE_FILE_EXTENTIONS_TO_IMPORT = ["", ".eps", ".EPS"]

  def initialize(bucketed_zip_filename, date, options={})
    @bucketed_zip_filename = bucketed_zip_filename
    @date = date
    @fog_aws_connection = options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }

    create_directories
  end

  def process
    if !zip_file_exists?
      download_eps_image_bundle
      unzip_file(
        uncompressed_eps_images_path,
        File.join(compressed_image_bundles_path, base_filename)
      )
    end
  end

  private

  def base_filename
    @base_filename ||= File.basename(bucketed_zip_filename)
  end

  def bucket_name
    SETTINGS["s3_buckets"]["zipped_eps_images"]
  end

  def compressed_image_bundles_path
    @compressed_image_bundles_path ||= GpoImages::FileLocationManager.compressed_image_bundles_path
  end

  def uncompressed_eps_images_path
    @uncompressed_eps_images_path ||= GpoImages::FileLocationManager.uncompressed_eps_images_path
  end

  def create_directories
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
      # NOTE: There are intentionally two zip_file.each blocks to ensure a queue
      # is built before processing on this queue starts.
      zip_contents.each do |file|
        if IMAGE_FILE_EXTENTIONS_TO_IMPORT.include?(File.extname(file.name))
          add_to_redis_set(file.name)
        end
      end
      zip_contents.each do |file|
        if IMAGE_FILE_EXTENTIONS_TO_IMPORT.include?(File.extname(file.name))
          path_with_file = File.join(destination, file.name)
          zip_contents.extract(file, path_with_file){ true }
          puts "Enqueuing GpoImages::BackgroundJob for #{file.name}..."
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
