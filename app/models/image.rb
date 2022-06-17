class Image < ApplicationModel
  include CloudfrontUtils
  extend ActiveHash::Associations::ActiveRecordExtensions
  mount_uploader :image, OriginalImageUploader, mount_on: :image_file_name

  has_many :image_variants, foreign_key: :identifier, primary_key: :identifier
  has_many :image_usages,
    :foreign_key => :identifier,
    :primary_key => :identifier
  belongs_to_active_hash :image_source, foreign_key: :source_id
  validates_presence_of :identifier
  validate :image_source_populated

  attr_accessor :skip_variant_generation

  # The intent of our db schema is that every image variant should have a corresponding original image record (though its image file name may be blank).  As such, when making image variants public, #make_public should be called on the original image, even if it's effectively a shell record.

  def make_public!
    change_s3_acl('public-read')
    image_variants.each do |image_variant|
      image_variant.make_public!
    end
    touch(:made_public_at)
  end

  def make_private!
    change_s3_acl('private')
    image_variants.each do |image_variant|
      image_variant.make_private!
    end
  end

  def regenerate_image_variants!(enqueue=false)
    if enqueue
      ImageVariantReprocessor.perform_async(identifier, ImageStyle.all.map(&:identifier))
    else
      ImageVariantReprocessor.new.perform(identifier, ImageStyle.all.map(&:identifier))
    end
  end

  private

  def change_s3_acl(acl) # Common ACL options: private, public-read
    s3_object = GpoImages::FogAwsConnection.new.get_s3_object(image_file_name, SETTINGS['s3_buckets']['original_images'])
    s3_object.acl = acl
    s3_object.save
  end

  def image_source_populated
    if image_file_name.present? && source_id.blank?
      errors.add(:source_id, "Image source must be populated for an image")
    end
  end
end
