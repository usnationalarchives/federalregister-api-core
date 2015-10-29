class GpoImages::FileConverter
  attr_reader :bucketed_zip_filename,
    :date,
    :fog_aws_connection

  IMAGE_FILE_EXTENTIONS_TO_IMPORT = [".eps", ".EPS"]
  IMAGE_FILE_EXTENTIONS_TO_IGNORE = [".tiff"]

  def initialize(bucketed_zip_filename, date, options={})
    @bucketed_zip_filename = bucketed_zip_filename
    @date = date
    @fog_aws_connection = options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }

    create_directories
  end

  def process
    unless zip_file_exists?
      download_eps_image_bundle
      unzip_file_and_process(
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
    GpoImages::FileLocationManager.compressed_image_bundles_path
  end

  def uncompressed_eps_images_path
    GpoImages::FileLocationManager.uncompressed_eps_images_path
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

  def unzip_file_and_process(destination, zip_file)
    Zip::ZipFile.open(zip_file) do |zip_contents|
      FileUtils.makedirs(destination)
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
        puts "Enqueuing GpoImages::BackgroundJob for #{file.name}..."
        Resque.enqueue(GpoImages::BackgroundJob, filename, bucketed_zip_filename, date)
      end
    end
  end

  def cast_to_eps(file)
    IMAGE_FILE_EXTENTIONS_TO_IMPORT.include?(
      File.extname(file.name)
    ) ? file.name : "#{file.name}.eps"
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
