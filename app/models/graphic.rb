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
  has_many :usages, :class_name => "GraphicUsage"
  has_many :entries, :through => :usages
  
  has_attached_file :graphic,
                    :styles => { :thumb => ["100", :gif], :large => ["460", :gif], :original => ["", :gif] },
                    :processors => [:auto_inverter],
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/amazon.yml",
                    :s3_alias_url => 'http://images.federalregister.gov.s3.amazonaws.com/',
                    :bucket => 'images.federalregister.gov',
                    :path => ":identifier/:style.:extension"
end
