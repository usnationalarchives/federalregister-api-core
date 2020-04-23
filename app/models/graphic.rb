class Graphic < ApplicationModel
  before_save :set_content_type

  has_many :usages, :class_name => "GraphicUsage"
  has_many :entries, :through => :usages

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
                    :processors => [:auto_inverter, :png_crush],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.secrets[:aws][:access_key_id],
                      :secret_access_key => Rails.application.secrets[:aws][:secret_access_key],
                      :s3_region => 'us-east-1'
                    },
                    :s3_host_alias => SETTINGS["s3_host_aliases"]["public_images"],
                    :s3_protocol => 'https',
                    :bucket => SETTINGS["s3_buckets"]["public_images"],
                    :path => ":identifier/:style.:extension",
                    :url => ':s3_alias_url'
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
end
