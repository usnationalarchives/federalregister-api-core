class EsEntrySearchResult < OpenStruct

  def highlights
    text = highlight
    if text
      text.values.join(' ... ')
    else
      ''
    end
  end

  def raw_text_updated_at
    #TODO: Fix this stub!!!  We need to add this attribute to the repository
    Time.current
  end

end
