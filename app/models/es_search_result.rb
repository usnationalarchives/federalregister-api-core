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


  def page_views
    {
      count:        PageViewCount.count_for(document_number, PageViewType::DOCUMENT),
      last_updated: PageViewCount.last_updated(PageViewType::DOCUMENT)
    }
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

end
