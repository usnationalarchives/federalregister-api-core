module GpoImages
  module ImageIdentifierNormalizer
    INVALID_BUCKET_CHARS = "#"

    def normalize_image_identifier(filename)
      image_identifier(filename).downcase.gsub(/#{INVALID_BUCKET_CHARS}/, '-')
    end

    def image_identifier(filename)
      filename.gsub('.eps',"")
    end
  end
end
