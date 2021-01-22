# A copy of this class exists in -web also (for xslt compilation). Besure to update both!
module GpoImages
  module ImageIdentifierNormalizer
    def normalize_image_identifier(filename)
      remove_extensions(filename).downcase
    end

    def remove_extensions(filename)
      filename.gsub(/\.?eps/i,"")
    end
  end
end
