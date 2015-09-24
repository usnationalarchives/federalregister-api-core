class GpoGraphic < ActiveRecord::Base
  before_save :set_content_type

  has_many :gpo_graphic_usages,
    :foreign_key => :identifier,
    :primary_key => :identifier

  has_many :entries,
    :through => :gpo_graphic_usages

  has_attached_file :graphic,
                    :styles => { :large => ["460", :png], :original => ["", :png] },
                    :processors => [:thumbnail],
                    :source_file_options => ["-density 300"],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => SECRETS["aws"]["access_key_id"],
                      :secret_access_key => SECRETS["aws"]["secret_access_key"]
                    },
                    :s3_permissions => :private,
                    :s3_protocol => 'https',
                    :bucket => proc { |attachment| attachment.instance.assigned_bucket },
                    :path => ":identifier/:style.:extension"

  named_scope :processed, :conditions => "graphic_file_name IS NOT NULL"
  named_scope :unprocessed, :conditions => "graphic_file_name IS NULL"

  def set_content_type
    self.graphic.instance_write(:content_type, 'image/png')
  end

  def move_to_public_bucket
    GpoImages::FogAwsConnection.new.move_directory_files_between_buckets(
      identifier,
      private_bucket,
      public_bucket
    )
  end

  def assigned_bucket
    publication_dates = gpo_graphic_usages.map{|u|u.entry.publication_date}
    if publication_dates.any?{|publication_date| publication_date <= Date.current}
      public_bucket
    else
      private_bucket
    end
  end

  private

  def public_bucket
    SETTINGS["public_processed_images_s3_bucket"]
  end

  def private_bucket
    SETTINGS["private_processed_images_s3_bucket"]
  end

end
