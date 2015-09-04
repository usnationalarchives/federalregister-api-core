class GpoGraphicUsage < ApplicationModel

  def entry
    Entry.find_by_document_number(document_number)
  end

end
