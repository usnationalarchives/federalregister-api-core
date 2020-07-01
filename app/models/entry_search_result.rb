class EntrySearchResult
  attr_reader :id

  def initialize(attributes={})
    @attributes = attributes
    @id         = attributes.delete(:id)
  end

  def publication_date
    Date.parse(@publication_date) if @publication_date
  end

  # http://localhost:3001/api/v1/documents.json?conditions[term]=8517&fields[]=abstract&fields[]=agencies&fields[]=document_number&fields[]=excerpts&fields[]=html_url&fields[]=publication_date&fields[]=title&fields[]=type&page=1&order=relevant&per_page=20
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
