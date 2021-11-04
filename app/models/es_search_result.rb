class EsSearchResult < OpenStruct
  include TextHelper

  def docket_id
    # Ensure interface matches with historical EntryApiRepresentation
    self['docket_id'].uniq.first
  end

  def docket_ids
    # Ensure interface matches with historical EntryApiRepresentation
    self['docket_id']
  end

  def highlights
    text = highlight
    if text
      text.values.join(' ... ')
    else
      ''
    end
  end

  def type
    entry_type #NOTE: The serializer/ES-stored "type" attribute is different than the "type" field returned in API requests, hence the override here.
  end

  def excerpts
    return excerpt if excerpt

    if abstract.present?
      truncate_words(abstract, length: 255)
    else
      nil
    end
  end

  def value(field_name)
    self.send(field_name)
  end

end
