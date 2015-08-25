require 'ruby-debug'

class GpoImages::BackgroundJob
  attr_reader :eps_filename, :zipped_filename, :ftp_transfer_date,
              :compressed_image_bundles_path, :uncompressed_eps_images_path,
              :processed_images_bucket_name, :temp_image_files_path

  def initialize(eps_filename, zipped_filename, ftp_transfer_date)
    @eps_filename = eps_filename
    @zipped_filename = zipped_filename
    @ftp_transfer_date = ftp_transfer_date
    @compressed_image_bundles_path = "tmp/gpo_images/compressed_image_bundles"
    @uncompressed_eps_images_path = "tmp/gpo_images/uncompressed_eps_images"
    @temp_image_files_path = "tmp/gpo_images/temp_image_files"
    @processed_images_bucket_name = 'processed.images.fr2.criticaljuncture.org.test' #TODO: Make domain dynamic
  end

  def process
    image = GpoGraphic.new(:identifier => eps_filename)
    image.graphic = File.open(File.join(temp_image_files_path, eps_filename))
    if image.save
      remove_from_redis_key
      remove_local_image
      debugger
      if redis_file_queue_empty?
        mark_zipfile_as_converted
        remove_zip_file
      end
    else
      raise "In development, problem saving image." #TODO: Remove stub.
    end
  end

  private

  def redis
    Redis.new
  end

  def remove_from_redis_key
    redis.srem("converted_files:#{zipped_filename}", eps_filename)
  end

  def mark_zipfile_as_converted
    redis.sadd("converted_files:#{ftp_transfer_date.to_s(:ymd)}", zipped_filename)
  end

  def redis_file_queue_empty?
    redis.scard(redis_key) == 0
  end

  def redis_key
    "converted_files:#{zipped_filename}"
  end

  def remove_local_image
    FileUtils.rm(File.join(temp_image_files_path, eps_filename))
  end

  def remove_zip_file
    FileUtils.rm(File.join(compressed_image_bundles_path, zipped_filename))
  end

end
