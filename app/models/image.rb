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

  def make_public!(invalidate_cloudfront: false)
    change_s3_acl('public-read')
    image_variants.each do |image_variant|
      image_variant.make_public!
    end
    touch(:made_public_at)
    if invalidate_cloudfront
      invalidate_image_identifier_keyspace!
    end
  end

  def make_private!(invalidate_cloudfront: false)
    change_s3_acl('private')
    image_variants.each do |image_variant|
      image_variant.make_private!
    end
    update!(made_public_at: nil)
    if invalidate_cloudfront
      invalidate_image_identifier_keyspace!
    end
  end

  def regenerate_image_variants!(enqueue=false, invalidate_cloudfront=false)
    if enqueue
      ImageVariantReprocessor.perform_async(
        identifier,
        ImageStyle.all.map(&:identifier),
        invalidate_cloudfront
      )
    else
      ImageVariantReprocessor.new.perform(
        identifier,
        ImageStyle.all.map(&:identifier),
        invalidate_cloudfront
      )
    end
  end

  def invalidate_image_identifier_keyspace!
    create_invalidation(SETTINGS['s3_buckets']['image_variants'], ["/#{identifier}*"]) #NOTE: S3 documentation suggests * expiries only count o
  end

  private

  def change_s3_acl(acl) # Common ACL options: private, public-read
    if image.file.nil?
      return
    end

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
