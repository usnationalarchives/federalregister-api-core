class OriginalImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include UploaderUtils

  if SETTINGS['images']['auto_generate_image_variants']
    after :store, :regenerate_variants!
  end

  # Choose what kind of storage to use for this uploader:
  if SETTINGS['images']['store_in_filesystem']
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
    self.fog_directory = SETTINGS['s3_buckets']['original_images']
  end

  def store_dir
    if SETTINGS['images']['store_in_filesystem']
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
      "#{model.identifier}.#{file.extension}" 
    end
  end

  private

  def regenerate_variants!(file)
    if model.skip_variant_generation
      return
    end

    ImageVariantReprocessor.new.perform(model.identifier, ImageStyle.all.map(&:identifier))
  end

end
