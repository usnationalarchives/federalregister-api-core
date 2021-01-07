class GpoImages::FileConverter
  attr_reader :bucketed_zip_filename,
    :date,
    :fog_aws_connection

  IMAGE_FILE_EXTENTIONS_TO_IMPORT = [".eps", ".EPS"]
  IMAGE_FILE_EXTENTIONS_TO_IGNORE = [".tiff", ".ini"]

  def initialize(bucketed_zip_filename, date, options={})
    @bucketed_zip_filename = bucketed_zip_filename
    @date = date
    @fog_aws_connection = options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }

    create_directories
  end

  def process
    if zip_file_exists?
      log "image package #{bucketed_zip_filename} for #{date} already exist - not processing (prior failure likely)"
    else
      log "processing image package #{bucketed_zip_filename} for #{date}"
      download_eps_image_bundle
      unzip_file_and_process(
        GpoImages::FileLocationManager.uncompressed_eps_images_path(package_identifier),
        File.join(GpoImages::FileLocationManager.compressed_image_bundles_path, base_filename)
      )
    end
  end

  private

  attr_reader :sourced_via_ecfr_dot_gov

  def base_filename
    @base_filename ||= File.basename(bucketed_zip_filename)
  end

  def package_identifier
    @package_identifier ||= File.basename(bucketed_zip_filename, '.zip')
  end

  def bucket_name
    SETTINGS["s3_buckets"]["zipped_eps_images"]
  end

  def create_directories
    FileUtils.makedirs GpoImages::FileLocationManager.compressed_image_bundles_path
    FileUtils.makedirs GpoImages::FileLocationManager.uncompressed_eps_images_path(package_identifier)
  end

  def download_eps_image_bundle
    file = fog_aws_connection.
      directories.
      get(bucket_name, :prefix => date.to_s(:ymd)).
      files.
      get(bucketed_zip_filename)

    if file.metadata["x-amz-meta-public-image"] #Check S3 metadata
      @sourced_via_ecfr_dot_gov = true
    else
      @sourced_via_ecfr_dot_gov = false
    end

    local_file = File.open(File.join(GpoImages::FileLocationManager.compressed_image_bundles_path, base_filename), "w")
    local_file.write(file.body.force_encoding('UTF-8'))

    local_file.close
  end

  def unzip_file_and_process(destination, zip_file)
    Zip::ZipFile.open(zip_file) do |zip_contents|
      FileUtils.mkdir_p(destination)
      build_processing_queue(zip_contents)
      enqueue_processing_jobs(zip_contents, destination)
    end
  end

  def build_processing_queue(files)
    files.each do |file|
      unless IMAGE_FILE_EXTENTIONS_TO_IGNORE.include?(File.extname(file.name))
        filename = cast_to_eps(file)
        add_to_redis_set(filename)
      end
    end
  end

  def enqueue_processing_jobs(files, destination)
    puts "enqueing conversion for GPO eps files to images for #{date}"
    files.each do |file|
      unless IMAGE_FILE_EXTENTIONS_TO_IGNORE.include?(File.extname(file.name))
        filename = cast_to_eps(file)
        file_path = File.join(destination, filename)
        files.extract(file, file_path){ true }
        log "Enqueuing GpoImages::BackgroundJob for #{file.name}..."
        Sidekiq::Client.enqueue(
          GpoImages::BackgroundJob,
          filename,
          bucketed_zip_filename,
          date,
          sourced_via_ecfr_dot_gov
        )
      end
    end
  end

  def cast_to_eps(file)
    IMAGE_FILE_EXTENTIONS_TO_IMPORT.include?(
      File.extname(file.name)
    ) ? file.name : "#{file.name}.eps"
  end

  def zip_file_exists?
    File.exist? File.join(
        GpoImages::FileLocationManager.compressed_image_bundles_path,
        base_filename
      )
  end

  def redis_key
    "images_left_to_convert:#{base_filename}"
  end

  def add_to_redis_set(filename)
    $redis.sadd(redis_key, filename)
  end

  def log(message)
    puts "[#{Time.now}] #{message}"
  end
end
