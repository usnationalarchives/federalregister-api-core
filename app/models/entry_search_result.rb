class EntrySearchResult
  attr_reader :id, :indexed_at

  def initialize(attributes={})
    @attributes = attributes
    @id         = attributes.delete(:id)
    @indexed_at = attributes.delete(:indexed_at)
  end

  def publication_date
    Date.parse(@publication_date) if @publication_date
  end

  def highlights
    text = attributes.dig(:highlight)
    if text
      text.values.join(' ... ')
    else
      ''
    end
  end

  private

  attr_reader :attributes

end
