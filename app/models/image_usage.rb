class ImageUsage < ApplicationModel
  belongs_to :image,
    :foreign_key => :identifier,
    :primary_key => :identifier
  belongs_to :entry,
    :foreign_key => :document_number,
    :primary_key => :document_number
end
