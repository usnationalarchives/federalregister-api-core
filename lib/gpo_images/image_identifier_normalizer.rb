# A copy of this class exists in -web also (for xslt compilation). Besure to update both!
module GpoImages
  module ImageIdentifierNormalizer
    def normalize_image_identifier(filename)
      image_identifier(filename).downcase
    end

    def image_identifier(filename)
      filename.gsub(/\.?eps/i,"")
    end
  end
end
