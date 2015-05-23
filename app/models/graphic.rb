class Graphic < ApplicationModel
  before_save :set_content_type

  has_many :usages, :class_name => "GraphicUsage"
  has_many :entries, :through => :usages

  has_attached_file :graphic,
                    :styles => { :large => ["684", :png], :original => ["", :png] },
                    :processors => [:auto_inverter],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => SECRETS['aws']['access_key_id'],
                      :secret_access_key => SECRETS['aws']['secret_access_key']
                    },
                    :s3_protocol => 'https',
                    :bucket => Rails.env.production? ? 'graphics.federalregister.gov' : "#{Rails.env}.graphics.federalregister.gov",
                    :path => ":identifier/:style.:extension"

  named_scope :extracted, :conditions => "graphic_file_name IS NOT NULL"

  def set_content_type
    self.graphic.instance_write(:content_type,'image/png')
  end

  def base_url
    graphic.url(:original, false).
      gsub(identifier,':identifier').
      gsub('original',':style')
  end
end
