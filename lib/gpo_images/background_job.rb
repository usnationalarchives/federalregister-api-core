module GpoImages
  class BackgroundJob
    include GpoImages::ImageIdentifierNormalizer

    include Sidekiq::Worker
    include Sidekiq::Throttled::Worker

    sidekiq_options :queue => :gpo_image_import, :retry => 0

    attr_reader :bucketed_zip_filename,
                :eps_filename,
                :ftp_transfer_date,
                :mark_public,
                :temp_image_files_path

    def perform(eps_filename, bucketed_zip_filename, ftp_transfer_date, sourced_via_ecfr_dot_gov)
      @eps_filename          = eps_filename
      @bucketed_zip_filename = bucketed_zip_filename
      @ftp_transfer_date     = ftp_transfer_date.is_a?(Date) ? ftp_transfer_date : Date.parse(ftp_transfer_date)
      @sourced_via_ecfr_dot_gov = sourced_via_ecfr_dot_gov

      gpo_graphic, gpo_graphic_package = find_or_create_gpo_graphic

      if gpo_graphic.save

        if gpo_graphic_package
          gpo_graphic_package.touch
        end
        if gpo_graphic.gpo_graphic_usages.present? || gpo_graphic.sourced_via_ecfr_dot_gov
          gpo_graphic.move_to_public_bucket
        end
        GpoGraphicMigrator.perform_async(gpo_graphic.identifier, Time.current.to_s(:iso))
        remove_from_redis_key
        remove_local_image

        if redis_file_queue_empty?
          mark_zipfile_as_converted
          remove_zip_file
          remove_local_image_directory
          remove_redis_key
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

    attr_reader :sourced_via_ecfr_dot_gov

    def package_identifier
      @package_identifier ||= File.basename(bucketed_zip_filename, '.zip')
    end

    def find_or_create_gpo_graphic
      gpo_graphic = GpoGraphic.find_or_initialize_by(identifier: identifier)

      if sourced_via_ecfr_dot_gov.blank? || gpo_graphic.sourced_via_ecfr_dot_gov.present? || gpo_graphic.id.blank?
      #eg only set the graphic/metadata if it's from SFTP, we're reprocessing an ECFR_sourced image, OR it's a new image
        gpo_graphic.sourced_via_ecfr_dot_gov = sourced_via_ecfr_dot_gov
        gpo_graphic.package_identifier = package_identifier
        gpo_graphic.save! # NOTE: Sometimes the paperclip image processing fails below; we want to ensure the package identifier is always saved for easier reprocessing.
        gpo_graphic.graphic = image

        gpo_graphic_package = gpo_graphic.gpo_graphic_packages.
          find_or_initialize_by(
            graphic_identifier: gpo_graphic.identifier,
            package_identifier: package_identifier
          )
        gpo_graphic_package.package_date = ftp_transfer_date
        return gpo_graphic, gpo_graphic_package
      else
        return gpo_graphic, nil
      end
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
      ).downcase
    end

    def redis
      $redis
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

    def remove_local_image_directory
      FileUtils.rm(
        GpoImages::FileLocationManager.uncompressed_eps_images_path(package_identifier),
        :force => true
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

    def remove_redis_key
      redis.del(redis_key)
    end

    def zipped_filename
      @zipped_filename ||= File.basename(bucketed_zip_filename)
    end
  end
end
