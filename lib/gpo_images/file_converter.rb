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
    @compressed_image_bundles_path = "tmp/gpo_images/compressed_image_bundles" #BC TODO: Make sure these paths reference the Rails root and use File.join
    @uncompressed_eps_images_path = "tmp/gpo_images/uncompressed_eps_images"
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
      files.get(bucketed_zip_filename)
    local_file = File.open(File.join(compressed_image_bundles_path, base_filename), "w")
    local_file.write(file.body)
    local_file.close
  end

  def unzip_file (destination, file) #BC TODO: clarify this with zip_file in lieu of 'file'
    #BC TODO: Pull the makedirs out of the loop
    Zip::ZipFile.open(file) do |zip_file|
      zip_file.each{|file| add_to_redis_set(file.name) if File.extname(file.name) == ".eps"} #Add explanatory comment.
      zip_file.each do |f|
        if File.extname(file.name) == ".eps" #BC TODO: Fix this bug so it's actually checking the file.
          f_path = File.join(destination, f.name)
          FileUtils.mkdir_p(File.dirname(f_path)) #BC TODO: Clean this area up.
          zip_file.extract(f, f_path) unless File.exist?(f_path)
          Resque.enqueue(GpoImages::BackgroundJob, f.name, bucketed_zip_filename, date)
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
