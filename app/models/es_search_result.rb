class EsSearchResult < OpenStruct
  include TextHelper

  def highlights
    text = highlight
    if text
      text.values.join(' ... ')
    else
      ''
    end
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
