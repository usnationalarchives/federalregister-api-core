class PublicInspectionDocumentSearchResult
  attr_reader :id,
    :agency_ids,
    :indexed_at,
    :special_filing,
    :title

  def initialize(attributes={})
    @attributes = attributes
    @id = attributes.delete(:id)
    @agency_ids = attributes.delete(:agency_ids)
    @publication_date = attributes.delete(:publication_date)
    @special_filing = attributes.delete(:special_filing)
    @title = attributes.delete(:title)
    @indexed_at = attributes.delete(:indexed_at)
  end

  def publication_date
    Date.parse(@publication_date) if @publication_date
  end

  def highlights
    (attributes.dig(:highlight) || {}).values.join(' ... ')
  end

  private

  attr_reader :attributes
end
