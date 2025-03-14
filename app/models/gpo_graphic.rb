class GpoGraphic < ActiveRecord::Base
  before_save :set_content_type

  has_many :gpo_graphic_usages,
    :foreign_key => :identifier,
    :primary_key => :identifier

  has_many :gpo_graphic_packages,
    :foreign_key => :graphic_identifier,
    :primary_key => :identifier,
    :dependent => :destroy

  has_many :graphic_styles, as: :styleable, foreign_type: :graphic_type, foreign_key: :graphic_id, dependent: :destroy

  has_attached_file :graphic,
                    :processors => [:gpo_image_converter, :png_crush],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.credentials.dig(:app, :aws, :s3, :access_key_id),
                      :secret_access_key => Rails.application.credentials.dig(:app, :aws, :s3, :secret_access_key),
                      :s3_region => 'us-east-1'
                    },
                    :s3_host_alias => (proc do |attachment|
                      if attachment.instance.sourced_via_ecfr_dot_gov || attachment.instance.gpo_graphic_usages.present?
                        Settings.app.aws.s3.host_aliases.public_images
                      else
                        Settings.app.aws.s3.host_aliases.private_images
                      end
                    end),
                    :s3_permissions => :private,
                    :s3_protocol => 'https',
                    :path => ":xml_identifier/:style.:extension",
                    :bucket => (proc do |attachment|
                      if attachment.instance.sourced_via_ecfr_dot_gov || attachment.instance.gpo_graphic_usages.present?
                        attachment.instance.public_bucket
                      else
                        attachment.instance.private_bucket
                      end
                    end),
                    :validate_media_type => false,
                    :url => ':s3_alias_url',
                    :styles => -> (file) { file.instance.paperclip_styles }
  do_not_validate_attachment_file_type :graphic

  Paperclip.interpolates(:xml_identifier) do |attachment, style|
    if attachment.instance.gpo_graphic_usages.present?
      attachment.instance.xml_identifier
    elsif attachment.instance.sourced_via_ecfr_dot_gov
      # This logic isn't used in FR, but is useful so that the correct url is returned when using methods like `gpo_graphic.graphic.url` for troubleshooting, otherwise an invalid lowercase URL will be returned.
      attachment.instance.identifier.upcase
    else
      attachment.instance.identifier
    end
  end

  Paperclip.interpolates(:style) do |attachment, style|
    if style.to_s == 'original_png'
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
    if sourced_via_ecfr_dot_gov
      s3_identifier = identifier.upcase
    else
      s3_identifier = identifier
    end

    GpoImages::FogAwsConnection.new.move_directory_files_between_buckets_and_rename(
      xml_identifier,
      s3_identifier,
      private_bucket,
      public_bucket,
      sourced_via_ecfr_dot_gov: sourced_via_ecfr_dot_gov
    )
  end

  def xml_identifier
    self.gpo_graphic_usages.first.try(:xml_identifier)
  end

  def public?
    sourced_via_ecfr_dot_gov || xml_identifier
  end

  def public_bucket
    Settings.app.aws.s3.buckets.public_images
  end

  def private_bucket
    Settings.app.aws.s3.buckets.private_images
  end

  def paperclip_styles
    {
      :medium => {
        :format          => :png,
        :convert_options => "-strip -unsharp 0"
      },
      :large => {
        :format          => :png,
        :convert_options => "-strip -unsharp 0"
      },
      :original_png => {
        :format          => :png,
        :geometry        => "100%",
        :convert_options => "-strip -unsharp 0 -fuzz 10% -transparent white"
      }
    }
  end

  def update_graphic_styles
    graphic_styles = []
    paperclip_styles.merge(original_style).each do |style_name, attributes|
      begin
        image_metadata = get_image_metadata(style_name)
      rescue OpenURI::HTTPError #i.e. skip generating a graphic style if image url is not valid
        puts "#{style_name} style for #{identifier} does not exist."
        next
      end
      graphic_styles << GraphicStyle.new({
        image_identifier: self.identifier.downcase,
        image_format:     attributes.fetch(:format),
        style_name:       style_name,
      }.merge(image_metadata))
    end

    self.graphic_styles = graphic_styles
  end


  private

  def original_style
    if sourced_via_ecfr_dot_gov
      {
        :original => {
          :format => :pdf,
        }
      }
    else
      {
        :original => {
          :format => :eps,
        }
      }
    end
  end

  EXPIRATION_TIME = 60
  def get_image_metadata(style_name)
    if public?
      url = graphic.url(style_name)
    else
      # This is needed for accessing images stored in the private bucket.
      url = graphic.expiring_url(EXPIRATION_TIME, style_name)
    end

    # A bug with ImageMagick 6.9.7-4 prevents `Geometry.from_file(url)`, hence the need for a manual tempfile.  See commit notes.
    temp_file = Tempfile.new
    temp_file.binmode

    url_contents = URI.open(url).read
    digest = Digest::SHA256.hexdigest(url_contents)
    temp_file << url_contents
    temp_file.close

    geometry = Paperclip::Geometry.from_file(temp_file.path)
    {
      digest: digest,
      height: geometry.height,
      width:  geometry.width,
    }
  end

end
