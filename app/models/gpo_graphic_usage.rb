class GpoGraphicUsage < ApplicationModel
  belongs_to :entry
  belongs_to :gpo_graphic
  
  def entry
    Entry.find_by_document_number(document_number)
  end

end
