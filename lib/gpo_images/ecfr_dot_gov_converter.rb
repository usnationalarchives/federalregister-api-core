module GpoImages
  class EcfrDotGovConverter
    include GpoImages::ImageIdentifierNormalizer
    include CloudfrontUtils

    include Sidekiq::Worker
    include Sidekiq::Throttled::Worker

    sidekiq_options :queue => :gpo_image_import, :retry => 0

    def perform(image_identifier, create_new_graphics)
      #TODO: Handle deletion of existing sourced_via_ecfr_dot_gov images.
      @image_identifier = normalize_image_identifier(image_identifier)

      gpo_graphic       = GpoGraphic.find_or_initialize_by(
        identifier:               image_identifier,
        sourced_via_ecfr_dot_gov: create_new_graphics
      )

      if gpo_graphic && (gpo_graphic.sourced_via_ecfr_dot_gov == false)
        return #Don't overwrite SFTP-sourced images
      else
        gpo_graphic.sourced_via_ecfr_dot_gov = true
        temp_file = Tempfile.new([image_identifier, '.pdf'])
        temp_file.binmode
        open(ecfr_pdf_url) do |url_file|
          temp_file.write(url_file.read)
        end
        temp_file.rewind

        gpo_graphic.graphic = temp_file
        gpo_graphic.save!

        gpo_graphic.move_to_public_bucket
        paths_for_expiry = ['medium','large','original'].map{|style| "/#{image_identifier.upcase}/#{style}.png"}
        paths_for_expiry << "/#{image_identifier.upcase}/original.pdf"

        create_invalidation(Settings.s3_buckets.public_images, paths_for_expiry)
      end
    end

    private

    attr_reader :image_identifier

    def ecfr_pdf_url
      "https://retired.ecfr.gov/graphics/pdfs/#{image_identifier}.pdf" #This url requires the downcased variant of image_identifier
    end

  end
end
