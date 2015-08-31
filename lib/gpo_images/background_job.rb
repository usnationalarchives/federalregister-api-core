require 'ruby-debug'

class GpoImages::BackgroundJob
  @queue = :gpo_image_import

  attr_reader :eps_filename, :zipped_filename, :ftp_transfer_date,
              :compressed_image_bundles_path, :uncompressed_eps_images_path,
              :temp_image_files_path, :bucketed_zip_filename

  def initialize(eps_filename, bucketed_zip_filename, ftp_transfer_date)
    @eps_filename = eps_filename
    @bucketed_zip_filename = bucketed_zip_filename
    @zipped_filename = File.basename(@bucketed_zip_filename) #BC TODO: Change this to base_filename
    @ftp_transfer_date = ftp_transfer_date.is_a?(Date) ? ftp_transfer_date : Date.parse(ftp_transfer_date)
    @compressed_image_bundles_path = "tmp/gpo_images/compressed_image_bundles"
    @uncompressed_eps_images_path = "tmp/gpo_images/uncompressed_eps_images"
  end

  def self.perform(eps_filename, zipped_filename, ftp_transfer_date)
    new(eps_filename, zipped_filename, ftp_transfer_date).perform
  end

  def perform
    image = find_or_create_gpo_graphic
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

  def find_or_create_gpo_graphic
    if GpoGraphic.find_by_identifier(identifier)
      image = GpoGraphic.find_by_identifier(identifier) #BC TODO: Move this outside the loop and execute if image to check instead so find isn't happending twice
      image.graphic = File.open(File.join(uncompressed_eps_images_path, eps_filename))
    else
      image = GpoGraphic.new(:identifier => identifier)
      image.graphic = File.open(File.join(uncompressed_eps_images_path, eps_filename)) #Make this a method so both paths in the loop can take advantage of it
      image.gpo_graphic_usages.build #BC TODO: Should be marked as public if it has been found in existence.
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
    GpoImages::ImagePackage.new(ftp_transfer_date, bucketed_zip_filename).mark_as_completed! #BC TODO: Test graceful failure w/null input--Race condition w/two jobs seeing the queue as empty
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
    FileUtils.rm(File.join(compressed_image_bundles_path, zipped_filename)) #BC TODO: Double-check this failure in console
  end

end
