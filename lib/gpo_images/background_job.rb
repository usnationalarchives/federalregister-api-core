require 'ruby-debug'

class GpoImages::BackgroundJob
  @queue = :gpo_image_import #TODO: BC Determine final queue location.

  attr_reader :eps_filename, :zipped_filename, :ftp_transfer_date,
              :compressed_image_bundles_path, :uncompressed_eps_images_path,
              :temp_image_files_path, :bucketed_zip_filename

  def initialize(eps_filename, bucketed_zip_filename, ftp_transfer_date)
    @eps_filename = eps_filename
    @bucketed_zip_filename = bucketed_zip_filename
    @zipped_filename = File.basename(@bucketed_zip_filename) #TODO: Change this to base_filename
    @ftp_transfer_date = ftp_transfer_date.is_a?(Date) ? ftp_transfer_date : Date.parse(ftp_transfer_date)
    @compressed_image_bundles_path = "tmp/gpo_images/compressed_image_bundles"
    @uncompressed_eps_images_path = "tmp/gpo_images/uncompressed_eps_images"
  end

  def self.perform(eps_filename, zipped_filename, ftp_transfer_date)
    new(eps_filename, zipped_filename, ftp_transfer_date).perform
  end

  def perform
    image = find_or_create_image
    if image.save
      remove_from_redis_key
      remove_local_image
      if redis_file_queue_empty?
        mark_zipfile_as_converted
        remove_zip_file
      end
    else
      Honeybadger.notify(
        :error_class   => "GpoGraphic failed to save",
        :error_message => image.errors.full_messages.to_sentence
      )
    end
  end

  private

  def find_or_create_image
    if GpoGraphic.find_by_identifier(identifier)
      image = GpoGraphic.find_by_identifier(identifier)
      image.graphic = File.open(File.join(uncompressed_eps_images_path, eps_filename))
    else
      image = GpoGraphic.new(:identifier => identifier)
      image.graphic = File.open(File.join(uncompressed_eps_images_path, eps_filename))
      image.gpo_graphic_usages.build
    end
    image
  end

  def identifier
    File.basename(eps_filename, File.extname(eps_filename))
  end

  def redis
    Redis.new
  end

  def remove_from_redis_key
    redis.srem(redis_key, eps_filename)
  end

  def mark_zipfile_as_converted
    GpoImages::ImagePackage.new(ftp_transfer_date, bucketed_zip_filename).mark_as_completed!
  end

  def redis_file_queue_empty?
    redis.scard(redis_key) == 0
  end

  def redis_key
    "images_left_to_convert:#{zipped_filename}"
  end

  def remove_local_image
    FileUtils.rm(File.join(uncompressed_eps_images_path, eps_filename))
  end

  def remove_zip_file
    FileUtils.rm(File.join(compressed_image_bundles_path, zipped_filename))
  end

end
