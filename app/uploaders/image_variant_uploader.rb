class ImageVariantUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include UploaderUtils

  # Choose what kind of storage to use for this uploader:
  if SETTINGS['images']['store_in_filesystem']
    storage :file
  else
    storage :fog
  end

  # define some uploader specific configurations in the initializer
  # to override the global configuration
  def initialize(*)
    super

    self.fog_credentials = {
      :provider               => 'AWS', # required
      :aws_access_key_id      => Rails.application.secrets[:aws][:access_key_id], # required
      :aws_secret_access_key  => Rails.application.secrets[:aws][:secret_access_key], # required
      :region => 'us-east-1'
    }
    self.fog_directory = SETTINGS['s3_buckets']['image_variants']
    self.asset_host = SETTINGS['s3_host_aliases']['image_variants'] #eg Cloudfront
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if SETTINGS['images']['store_in_filesystem']
      "#{Rails.root}/data/#{model.class.to_s.underscore}/#{model.identifier}"
    else
      "#{model.identifier}"
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process :gpo_image_convert
  process :png_crush
  process :store_content_type
  process :store_dimensions
  process :store_size
  process :store_sha

  def gpo_image_convert
    if skip_supplemental_image_processing?
      return
    end

    output_path = "#{Rails.root}/tmp/#{model.identifier}.png"
    image_magick_settings = ImageConversionSettingsBuilder.new(
      current_path,
      model.original_image.image_source,
      model.image_style
    ).perform
    `convert #{image_magick_settings} '#{current_path}' #{model.image_style.image_magick_operators} '#{output_path}'` #NOTE: "Generally speaking a setting should come before an image filename and an image operator after the image filename."
  
    File.rename output_path, current_path
  end

  def png_crush
    Terrapin::CommandLine.new("pngcrush -ow -rem alla -nofilecheck -reduce -m 7 #{current_path}").run
  end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if original_filename
      if dynamically_determine_file_extension?
        "#{model.identifier}_#{model.style}.#{file.extension}" 
      else
        "#{model.identifier}_#{model.style}.png" 
      end
    end
  end

  private

  def skip_supplemental_image_processing? #eg image resizing/compression/etc
    model.original_image.image_file_name.blank? #indicates no original image is available and thus we're assuming the variant was sourced from the old S3 bucket as a direct backfill
  end

  def dynamically_determine_file_extension?
    model.original_image.image_file_name.blank?
  end

end
