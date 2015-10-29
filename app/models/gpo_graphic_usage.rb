class GpoGraphicUsage < ApplicationModel
  belongs_to :entry,
    :foreign_key => :document_number,
    :primary_key => :document_number

  belongs_to :gpo_graphic,
    :foreign_key => :identifier,
    :primary_key => :identifier
end
