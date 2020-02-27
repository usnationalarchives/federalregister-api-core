class EntrySearchResult
  attr_reader :id, :attributes #TODO: possibly move :attributes to private interface

  def initialize(attributes={})
    @attributes = attributes
    @id         = attributes.delete(:id)
  end

  def publication_date
    Date.parse(@publication_date) if @publication_date
  end

  def highlights
    attributes.dig(:highlight).values.join(' ... ')
  end

end
