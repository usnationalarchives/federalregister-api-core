# == Schema Information
#
# Table name: graphics
#
#  id                   :integer(4)      not null, primary key
#  identifier           :string(255)
#  usage_count          :integer(4)      default(0), not null
#  graphic_file_name    :string(255)
#  graphic_content_type :string(255)
#  graphic_file_size    :integer(4)
#  graphic_updated_at   :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  inverted             :boolean(1)
#

class Graphic < ApplicationModel
  before_save :set_content_type

  has_many :usages, :class_name => "GraphicUsage"
  has_many :entries, :through => :usages
  
  has_attached_file :graphic,
                    :styles => { :thumb => ["100", :gif], :large => ["460", :gif], :original => ["", :gif] },
                    :processors => [:auto_inverter],
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/amazon.yml",
                    :s3_protocol => 'https',
                    :bucket => 'images.federalregister.gov',
                    :path => ":identifier/:style.:extension"

  named_scope :extracted, :conditions => "graphic_file_name IS NOT NULL"

  def set_content_type
    self.graphic.instance_write(:content_type,'image/gif')
  end
end
