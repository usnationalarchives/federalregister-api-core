class GpoGraphic < ActiveRecord::Base

  has_attached_file :graphic,
                    #BC TODO: Define :styles key for image format.
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => SECRETS["s3"]["username"]
                      :secret_access_key => SECRETS["s3"]["password"]
                    },
                    :s3_protocol => 'https',
                    :bucket => 'processed.images.fr2.criticaljuncture.org.test', #BC TODO: Make this dyanmic for the domain.
                    :path => ":identifier/:style.:extension"

end
