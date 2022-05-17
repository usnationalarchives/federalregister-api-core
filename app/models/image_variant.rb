class ImageVariant < ApplicationModel
  extend ActiveHash::Associations::ActiveRecordExtensions
  mount_uploader :image, ImageVariantUploader, mount_on: :image_file_name
  belongs_to_active_hash :image_style, foreign_key: :style, primary_key: :identifier
  belongs_to :original_image, class_name: "Image", foreign_key: :identifier, primary_key: :identifier
  validates_presence_of :identifier, :style

  def regenerate!
    ImageVariantReprocessor.new.perform(identifier, style)
  end

end
