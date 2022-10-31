class Graphic < ApplicationModel
  before_save :set_content_type

  has_many :usages, :class_name => "GraphicUsage"
  has_many :entries, :through => :usages

  has_attached_file :graphic,
                    :processors => [:auto_inverter, :gpo_image_converter,  :png_crush],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.secrets[:aws][:access_key_id],
                      :secret_access_key => Rails.application.secrets[:aws][:secret_access_key],
                      :s3_region => 'us-east-1'
                    },
                    :s3_host_alias => Settings.s3_host_aliases.public_images,
                    :s3_protocol => 'https',
                    :bucket => Settings.s3_buckets.public_images,
                    :path => ":identifier/:style.:extension",
                    :url => ':s3_alias_url',
                    :styles => -> (file) { file.instance.paperclip_styles }
  do_not_validate_attachment_file_type :graphic

  scope :extracted, -> { where("graphic_file_name IS NOT NULL") }

  def set_content_type
    self.graphic.instance_write(:content_type,'image/png')
  end

  def base_url
    graphic.url(:original, false).
      gsub(identifier,':identifier').
      gsub('original',':style')
  end

  def paperclip_styles
    {
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

  def sourced_via_ecfr_dot_gov
    false
  end

end
