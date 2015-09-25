module GpoImages
  module ImageIdentifierNormalizer
    INVALID_BUCKET_CHARS = "#"

    def normalize_image_identifier(filename)
      filename.downcase.gsub('.eps',"").gsub(/#{INVALID_BUCKET_CHARS}/, '-')
    end
  end
end
