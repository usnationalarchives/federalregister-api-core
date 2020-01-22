class GpoGraphic < ActiveRecord::Base
  before_save :set_content_type

  has_many :gpo_graphic_usages,
    :foreign_key => :identifier,
    :primary_key => :identifier

  has_many :gpo_graphic_packages,
    :foreign_key => :graphic_identifier,
    :primary_key => :identifier,
    :dependent => :destroy

  has_attached_file :graphic,
                    :styles => {
                      :large => {
                        :format => :png,
                        :geometry => "460",
                        :convert_options => "-strip -unsharp 0"
                      },
                      :original_png => {
                        :format => :png,
                        :geometry => "100%",
                        :convert_options => "-strip -unsharp 0 -fuzz 10% -transparent white",
                      }
                    },
                    :processors => [:gpo_image_converter, :png_crush],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.secrets[:aws][:access_key_id],
                      :secret_access_key => Rails.application.secrets[:aws][:secret_access_key],
                      :s3_region => 'us-east-1'
                    },
                    :s3_permissions => :private,
                    :s3_protocol => 'https',
                    :bucket => proc { |attachment| attachment.instance.gpo_graphic_usages.present? ? attachment.instance.public_bucket : attachment.instance.private_bucket },
                    :path => ":xml_identifier/:style.:extension"
  do_not_validate_attachment_file_type :graphic

  Paperclip.interpolates(:xml_identifier) do |attachment, style|
    if attachment.instance.gpo_graphic_usages.present?
      attachment.instance.xml_identifier
    else
      attachment.instance.identifier
    end
  end

  Paperclip.interpolates(:style) do |attachment, style|
    if style == :original_png
      :original
    else
      style
    end
  end

  scope :processed, -> { where("graphic_file_name IS NOT NULL") }
  scope :unprocessed, -> {where("graphic_file_name IS NULL") }

  def entries
    @entries ||= gpo_graphic_usages.includes(:entry).map(&:entry)
  end

  def set_content_type
    self.graphic.instance_write(:content_type, 'image/png')
  end

  def move_to_public_bucket
    GpoImages::FogAwsConnection.new.move_directory_files_between_buckets_and_rename(
      xml_identifier,
      identifier,
      private_bucket,
      public_bucket
    )
  end

  def xml_identifier
    self.gpo_graphic_usages.first.try(:xml_identifier)
  end

  def public_bucket
    SETTINGS["s3_buckets"]["public_images"]
  end

  def private_bucket
    SETTINGS["s3_buckets"]["private_images"]
  end

end
