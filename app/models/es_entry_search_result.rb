class EsEntrySearchResult < OpenStruct

  def highlights
    text = highlight
    if text
      text.values.join(' ... ')
    else
      ''
    end
  end

end
