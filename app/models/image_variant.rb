class ImageVariant < ApplicationModel
  extend ActiveHash::Associations::ActiveRecordExtensions
  mount_uploader :image, ImageVariantUploader, mount_on: :image_file_name
  belongs_to_active_hash :image_style, foreign_key: :style, primary_key: :identifier
  belongs_to :original_image, class_name: "Image", foreign_key: :identifier, primary_key: :identifier
  validates_presence_of :identifier, :style

  attr_accessor :skip_storing_image_specific_metadata

  def regenerate!(invalidate_cloudfront=false)
    ImageVariantReprocessor.new.perform(identifier, style, invalidate_cloudfront)
  end

  def make_public!
    change_s3_acl('public-read')
  end

  def make_private!
    change_s3_acl('private')
  end

  private

  def change_s3_acl(acl) # Common ACL options: private, public-read
    if image.file.nil?
      return
    end

    key = "#{image.store_dir}/#{image_file_name}"
    s3_object = GpoImages::FogAwsConnection.new.get_s3_object(key, Settings.s3_buckets.image_variants)
    if s3_object.nil?
      Honeybadger.notify("Unable to fetch S3 object: #{key} in #{Settings.s3_buckets.image_variants}")
    else
      s3_object.acl = acl
      s3_object.save
    end
  end

end
