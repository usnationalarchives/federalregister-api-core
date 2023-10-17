# This job downloads EPS files from the image holding tank,
# saves the original EPS image to a long-lived S3 bucket and generates
# the image variants, saving them to S3 as well.
class ImagePipeline::EnvironmentImageDownloader
  extend Memoist
  include Sidekiq::Worker
  include GpoImages::ImageIdentifierNormalizer
  include ImagePipeline::ImageDescrunching

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  def perform(s3_key)
    @s3_key = s3_key
    @connection = GpoImages::FogAwsConnection.new.connection

    return if already_downloaded_or_not_found?

    begin
      response = connection.get_object(image_holding_tank_s3_bucket, s3_key)
      temp_file = File.new(s3_key, "w")
      temp_file.binmode
      temp_file.puts(response.body)
      temp_file.rewind

      image = Image.find_or_initialize_by(
        identifier: normalized_image_identifier,
      )
      image.source_id = get_s3_tags.fetch('image_source_id')

      # Attempt descrunch if needed
      if gpo_scrunched_image?(temp_file.path)
        descrunch!(temp_file.path)
      end

      # Ensure we remove existing errors
      image.assign_attributes(image: temp_file, error: nil)

      if !image.image.present?
        # In some cases, it appears that MiniMagick may silently rescue invalid
        # image errors.  If we hit this block, make sure to add handling that
        # allows for saving of the invalid image.
        raise NotImplementedError
      end

      persist_image!(image)
    rescue Excon::Error::NotFound => e
      raise "Object not found on S3: #{s3_key}"
    rescue Timeout::Error
      image.skip_storing_image_specific_metadata = true
      image.skip_variant_generation              = true

      image.assign_attributes(
        error: 'minimagick_processing_timeout',
        image: temp_file
      )
      persist_image!(image)
    rescue DescrunchFailure, DescrunchTimeoutFailure, DescrunchHardTimeoutFailure => e
      if image.image.present? && image.error.blank?
        # no-op: Don't overwrite valid images with invalid images
      else
        # Resave the bad image and bypass the calculation/storage of
        # image-specific metadata and generating variants.
        image.skip_storing_image_specific_metadata = true
        image.skip_variant_generation = true
        image.assign_attributes(
          error: e.class.name.demodulize,
          image: temp_file
        )
        persist_image!(image)
      end
    rescue MiniMagick::Invalid => e
      # Resave the bad image and bypass the calculation/storage of
      # image-specific metadata and generating variants.
      image.skip_storing_image_specific_metadata = true
      image.skip_variant_generation = true
      image.assign_attributes(
        error: e.class.to_s,
        image: temp_file
      )
      persist_image!(image)
    ensure
      if File.exists? temp_file.path
        File.delete(temp_file.path)
      end
    end

    # Update S3 object tags
    s3_tags = get_s3_tags

    # There is a possible race condition here--eg PROD fetches tags,
    # staging updates tags to indicate it's downloaded the file, and then
    # PROD updates tags and does not include the staging downloaded at tag.
    # In this case, staging will simply re-download.
    put_s3_tags(
      s3_tags.merge(downloaded_at_tag => Time.current.to_s(:iso))
    )

    # Enqueue job to check on removing from holding tank
    ImagePipeline::ImageHoldingTankRemover.perform_in(1.minutes, s3_key)
  end

  private

  attr_reader :s3_key, :connection

  def persist_image!(image)
    if image.image_usages.present?
      image.image.fog_public = true
    else
      image.image.fog_public = false
    end
    image.save!
  end

  def normalized_image_identifier
    normalize_image_identifier(s3_key)
  end
  memoize :normalize_image_identifier

  def image_holding_tank_s3_bucket
    Settings.app.aws.s3.buckets.image_holding_tank
  end

  def already_downloaded_or_not_found?
    begin
      get_s3_tags[downloaded_at_tag]
    rescue Excon::Error::NotFound => e
      # If the image does not exist in the holding tank and we have an image
      # already stored in the image originals, assume the image has been
      # downloaded and it has already been deleted from the holding tank by the
      # ImageHoldingTankRemover
      if Image.where.not(image_file_name: nil).find_by(identifier: normalized_image_identifier)
        true
      else
        raise e
      end
    end
  end

  def get_s3_tags
    response = connection.get_object_tagging(
      image_holding_tank_s3_bucket,
      s3_key
    )
    response.body.fetch('ObjectTagging')
  end

  def put_s3_tags(tags)
    connection.put_object_tagging(
      image_holding_tank_s3_bucket,
      s3_key,
      tags
    )
  end

  def downloaded_at_tag
    "#{Rails.env.titleize}DownloadedAt"
  end

end
