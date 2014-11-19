class Graphic < ApplicationModel
  before_save :set_content_type

  has_many :usages, :class_name => "GraphicUsage"
  has_many :entries, :through => :usages

  has_attached_file :graphic,
                    :styles => { :large => ["460", :png], :original => ["", :png] },
                    :processors => [:auto_inverter],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => SECRETS['aws']['access_key_id'],
                      :secret_access_key => SECRETS['aws']['secret_access_key']
                    },
                    :s3_protocol => 'https',
                    :bucket => 'images.federalregister.gov',
                    :path => ":identifier/:style.:extension"

  named_scope :extracted, :conditions => "graphic_file_name IS NOT NULL"

  def set_content_type
    self.graphic.instance_write(:content_type,'image/png')
  end
end
