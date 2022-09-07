module UploaderUtils
  extend Memoist
  MIGRATION_MADE_PUBLIC_AT_TIMESTAMP = Time.new(2022,1,1) #Specifying a static time so it's clearer the image was not made public automatically via the image pipeline

  private

  def store_content_type
    if model.skip_storing_image_specific_metadata
      return
    end

    if file && model
      model.image_content_type = minimagick_wrapped_image[:mime_type]
      file.content_type        = minimagick_wrapped_image[:mime_type] # This manually sets the image's content type in S3.  Without this, Carrierwave will incorrectly set the image's content type based on the original file's extension (eg EPS), even though image magick is changing the file's extension to PNG. This has the unpleasant result of causing images not to be loaded inline in the browser, but downloaded to the filesystem instead.
    end
  end

  def store_dimensions
    if model.skip_storing_image_specific_metadata
      return
    end

    if file && model
      model.image_width, model.image_height = minimagick_wrapped_image[:dimensions]
    end
  end

  def store_sha
    if file && model
      model.image_sha = Digest::MD5.file(current_path).hexdigest
    end
  end

  def store_size
    if file && model
      model.image_size = file.size
    end
  end

  def minimagick_wrapped_image
    ::MiniMagick::Image.open(file.file)
  end
  memoize :minimagick_wrapped_image

end
