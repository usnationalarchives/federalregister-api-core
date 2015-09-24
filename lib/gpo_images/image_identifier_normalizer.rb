module GpoImages
  module ImageIdentifierNormalizer
    def normalize_image_identifier(filename)
      filename.downcase.gsub('.eps',"")
    end
  end
end
