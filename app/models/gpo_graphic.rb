class GpoGraphic < ActiveRecord::Base
  before_save :set_content_type

  has_many :gpo_graphic_usages, :foreign_key => :identifier, :primary_key => :identifier

  has_attached_file :graphic,
                    :styles => { :large => ["460", :png], :original => ["", :png] },
                    :processors => [:thumbnail],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => SECRETS["aws"]["access_key_id"],
                      :secret_access_key => SECRETS["aws"]["secret_access_key"]
                    },
                    :s3_permissions => :private,
                    :s3_protocol => 'https',
                    :bucket => 'processed.images.fr2.criticaljuncture.org.test', #BC TODO: Make this dyanmic for the domain.
                    :path => ":identifier/:style.:extension"

  def set_content_type
    self.graphic.instance_write(:content_type, 'image/png')
  end

end
