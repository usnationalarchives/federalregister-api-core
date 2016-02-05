# An copy of this class exists in -web also (for xslt compilation). Besure to update both!
module GpoImages
  module ImageIdentifierNormalizer
    INVALID_BUCKET_CHARS = "#"

    def normalize_image_identifier(filename)
      filename.downcase.gsub('.eps',"").gsub(/#{INVALID_BUCKET_CHARS}/, '-')
    end
  end
end
