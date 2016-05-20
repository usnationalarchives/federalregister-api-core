module GpoImages
  class BackgroundJob
    include GpoImages::ImageIdentifierNormalizer
    @queue = :gpo_image_import

    attr_reader :bucketed_zip_filename,
                :eps_filename,
                :ftp_transfer_date,
                :mark_public,
                :temp_image_files_path

    def initialize(eps_filename, bucketed_zip_filename, ftp_transfer_date)
      @eps_filename = eps_filename
      @bucketed_zip_filename = bucketed_zip_filename
      @ftp_transfer_date = ftp_transfer_date.is_a?(Date) ? ftp_transfer_date : Date.parse(ftp_transfer_date)
    end

    def self.perform(eps_filename, zipped_filename, ftp_transfer_date)
      new(eps_filename, zipped_filename, ftp_transfer_date).perform
    end

    def perform
      gpo_graphic = find_or_create_gpo_graphic

      if gpo_graphic.save
        gpo_graphic.move_to_public_bucket if gpo_graphic.gpo_graphic_usages.present?
        remove_from_redis_key
        remove_local_image

        if redis_file_queue_empty?
          mark_zipfile_as_converted
          remove_zip_file
        end
      else
        Honeybadger.notify(
          :error_class   => "GpoGraphic failed to save",
          :error_message => gpo_graphic.errors.full_messages.to_sentence,
          :parameters    => {
            :bucketed_zip_filename => bucketed_zip_filename,
            :eps_filename => eps_filename,
            :ftp_transfer_date => ftp_transfer_date,
            :identifier => identifier,
            :package_identifier => package_identifier
          }
        )
      end
    end

    private

    def package_identifier
      @package_identifier ||= File.basename(bucketed_zip_filename, '.zip')
    end

    def find_or_create_gpo_graphic
      gpo_graphic = GpoGraphic.find_or_initialize_by_identifier(identifier)
      gpo_graphic.graphic = image
      gpo_graphic.package_identifier = package_identifier

      gpo_graphic_package = GpoGraphicPackage.
        find_or_initialize_by_graphic_identifier_and_package_identifier(
          gpo_graphic.identifier,
          package_identifier
        )
      gpo_graphic_package.package_date = ftp_transfer_date

      gpo_graphic.gpo_graphic_packages << gpo_graphic_package
      gpo_graphic
    end

    def image
      @image ||= File.open(
        File.join(
          GpoImages::FileLocationManager.uncompressed_eps_images_path(package_identifier),
          eps_filename
        )
      )
    end

    def identifier
      normalize_image_identifier(
        File.basename(eps_filename, File.extname(eps_filename))
      )
    end

    def redis
      @redis ||= Redis.new
    end

    def remove_from_redis_key
      redis.srem(redis_key, eps_filename)
    end

    def mark_zipfile_as_converted
      GpoImages::ImagePackage.new(ftp_transfer_date, bucketed_zip_filename).mark_as_complete!
    end

    def redis_file_queue_empty?
      redis.scard(redis_key) == 0
    end

    def redis_key
      "images_left_to_convert:#{zipped_filename}"
    end

    def remove_local_image
      FileUtils.rm(
        File.join(
          GpoImages::FileLocationManager.uncompressed_eps_images_path(package_identifier),
          eps_filename
        )
      )
    end

    def remove_zip_file
      FileUtils.rm(
        File.join(
          GpoImages::FileLocationManager.compressed_image_bundles_path,
          zipped_filename
        ),
        :force => true
      )
    end

    def zipped_filename
      @zipped_filename ||= File.basename(bucketed_zip_filename)
    end
  end
end
