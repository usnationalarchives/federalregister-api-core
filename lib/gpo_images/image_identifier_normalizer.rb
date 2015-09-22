module GpoImages
  module ImageIdentifierNormalizer

  def normalize_image_identifier(filename)
    filename.
    gsub('.eps',"").
    gsub('.EPS',"").
    downcase
  end

  end
end
