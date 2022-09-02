# A copy of this class exists in -web also (for xslt compilation). Besure to update both!
module GpoImages
  module ImageIdentifierNormalizer
    def normalize_image_identifier(filename)
      if SETTINGS['feature_flags']['use_carrierwave_images_in_api']
        remove_extensions(filename).upcase
      else
        remove_extensions(filename).downcase
      end
    end

    def remove_extensions(filename)
      filename.gsub(/\.?eps/i,"")
    end
  end
end
