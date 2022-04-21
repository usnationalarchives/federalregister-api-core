class ImageUsage < ApplicationModel
  belongs_to :image,
    :foreign_key => :identifier,
    :primary_key => :identifier
end
