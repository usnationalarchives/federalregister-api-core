class OriginalImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include UploaderUtils

  after :store, :regenerate_variants!

  # Choose what kind of storage to use for this uploader:
  if Settings.app.images.store_in_filesystem
    storage :file
  else
    storage :fog
  end

  def initialize(*)
    super

    self.fog_credentials = {
      :provider               => 'AWS', # required
      :aws_access_key_id      => Rails.application.secrets[:aws][:access_key_id], # required
      :aws_secret_access_key  => Rails.application.secrets[:aws][:secret_access_key], # required
      :region => 'us-east-1'
    }
    self.fog_directory = Settings.app.aws.s3.buckets.original_images
  end

  def store_dir
    if Settings.app.images.store_in_filesystem
      "#{Rails.root}/data/#{model.class.to_s.underscore}/#{model.identifier}"
    else
      nil #ie store at root level
    end
  end

  process :store_content_type
  process :store_dimensions
  process :store_size
  process :store_sha

  def filename
    if original_filename
      "#{model.identifier}#{file_extension}"
    end
  end

  private

  def file_extension
    # This is needed because image formats typically contain periods (eg ER11AU04.555) whose suffixes will be treated as file extensions if simply calling file#extension
    case model.image_content_type
    when "image/ps", "image/eps"
      ".eps"
    when "image/tiff"
      ".tiff"
    when "image/png"
      ".png"
    end
  end

  def regenerate_variants!(file)
    if model.skip_variant_generation
      return
    end

    ImageVariantReprocessor.new.perform(
      model.identifier,
      ImageStyle.all.map(&:identifier),
      false
    )
  end

end
