# This class is intended to populates the ImageVariant table (NOT the Image table) with existing S3 files.  We don't currently have readily-available access to the existing originals for pre-2015 documents and so we made the decision to backfill the ImageVariant table based on the images available via the existing graphics table.

class GraphicMigrator
  include Sidekiq::Worker
  include CloudfrontUtils

  sidekiq_options :queue => :gpo_image_import, :retry => 0


  def perform(graphic_id)
    graphic                     = Graphic.find(graphic_id)
    normalized_image_identifier = graphic.identifier.upcase
   
    image = Image.find_or_initialize_by(
      identifier: normalized_image_identifier,
    )
    if image.image_file_name.present?
      return #ie if we have an original image, abort.  This process is meant to backfill when the original is not available.
    else
      image.assign_attributes(made_public_at: UploaderUtils::MIGRATION_MADE_PUBLIC_AT_TIMESTAMP, skip_variant_generation: true)
      image.save!
      image_variant = ImageVariant.find_or_initialize_by(
        identifier: normalized_image_identifier,
        style:      ImageStyle::ORIGINAL_SIZE.identifier
      )

      # Hard-coding this to the production URL since it is a better representation of what is actually available.  There is a large divergence between staging/production image data and in theory the production data should be more robust.
      url_sans_extension = "https://images.federalregister.gov/#{graphic.identifier}/original"
      if valid_url?("#{url_sans_extension}.gif") #Deliberately prioritize GIF if available.  Seems sharper than PNG (eg ER19JN12.007)
        remote_image_url = "#{url_sans_extension}.gif"
      elsif valid_url?("#{url_sans_extension}.png")
        remote_image_url = "#{url_sans_extension}.png"
      else
        raise "GIF and PNG not available for graphic #{graphic_id}: #{url_sans_extension}.png / #{url_sans_extension}.gif"
      end

      image_variant.assign_attributes(
        identifier:       normalized_image_identifier,
        style:            ImageStyle::ORIGINAL_SIZE.identifier,
        remote_image_url: remote_image_url,
      )
      image_variant.image.fog_public = true

      image_variant.save!
      create_invalidation(Settings.s3_buckets.image_variants, ["/#{image_variant.image.path}"])
    end
  end

  private

  def valid_url?(url)
    begin 
      Faraday.head(url).status == 200
    rescue Faraday::ConnectionFailed
      false
    end
  end

end
