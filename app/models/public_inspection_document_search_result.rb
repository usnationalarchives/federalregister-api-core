class PublicInspectionDocumentSearchResult
  attr_reader :agency_ids,
    :special_filing,
    :title

  def initialize(attributes={})
    @agency_ids = attributes.delete(:agency_ids)
    @publication_date = attributes.delete(:publication_date)
    @special_filing = attributes.delete(:special_filing)
    @title = attributes.delete(:title)
  end

  def publication_date
    Date.parse(@publication_date) if @publication_date
  end
end
