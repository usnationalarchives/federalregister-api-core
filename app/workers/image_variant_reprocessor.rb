class ImageVariantReprocessor
  include Sidekiq::Worker
  include CloudfrontUtils

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  RACE_CONDITION_RETRY_LIMIT = 1
  def perform(image_identifier, image_style_identifiers, invalidate_cloudfront)
    image = Image.find_by_identifier!(image_identifier)
    if image.image_file_name.blank?
      raise "Cannot reprocess #{image_variant.identifier}. Its original image is missing."
    end

    retries = 0
    begin
      Array.wrap(image_style_identifiers).each do |style|
          image_variant = image.image_variants.detect{|x| x.style == style} || image.image_variants.build(
            style: style,
          )

          image_variant.image = image.image.file
      
          if image.made_public_at.present?
            image_variant.image.fog_public = true
          else
            image_variant.image.fog_public = false
          end
          image_variant.save!
      end
    rescue ActiveRecord::RecordNotUnique => e
      # NOTE: In some cases, both "test_image" and "test_image.eps" are uploaded to SFTP.  Handle a race condition in production where one Sidekiq process picks up "test_image" and one Sidekiq process picks up "test_image.eps" simultaneously.  If so, attempt to reprocess all the variants.
      if retries < RACE_CONDITION_RETRY_LIMIT
        retries += 1
        retry
      else
        raise e
      end
    end

    if invalidate_cloudfront
      create_invalidation(Settings.s3_buckets.image_variants, ["/#{image.identifier}*"]) 
    end
    image.touch(:updated_at)
  end

end
