class GpoGraphicPackage < ActiveRecord::Base
  belongs_to :gpo_graphic,
    :foreign_key => :graphic_identifier,
    :primary_key => :identifier
end
