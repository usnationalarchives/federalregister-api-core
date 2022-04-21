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

  if SETTINGS['images']['auto_generate_image_variants']
    after_save :generate_variants
  end

  attr_accessor :skip_variant_generation

  # The intent of our db schema is that every image variant should have a corresponding original image record (though its image file name may be blank).  As such, when making image variants public, #make_public should be called on the original image, even if it's effectively a shell record.
  def make_public! 
    if made_public_at.blank?
      self.image.fog_public = true
      self.image.recreate_versions! # We're regenerating the image in S3 using #recreate_versions! in order to make it public.  In the future, we may want to refactor so we're making a lower-level API call to S3 to change private to public.

      image_variants.each do |image_variant|
        image_variant.image.fog_public = true
        image_variant.image.recreate_versions!
      end
      touch(:made_public_at)
    end
  end

  private

  def generate_variants
    if image_file_name.blank? || skip_variant_generation
      return
    end

    %w(original_size medium large).each do |style|
      variant = image_variants.detect{|x| x.style == style} || image_variants.build(
        style: style,
      )

      variant.identifier = self.identifier
      variant.image = self.image.file
      if self.made_public_at.present?
        variant.image.fog_public = true
      else
        variant.image.fog_public = false
      end
      variant.save!
      create_invalidation(SETTINGS['s3_buckets']['image_variants'], "#{variant.image.path}")
    end
    touch(:updated_at)
  end

  def image_source_populated
    if image_file_name.present? && source_id.blank?
      errors.add(:source_id, "Image source must be populated for an image")
    end
  end
end
