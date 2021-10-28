class EsSearchResult < OpenStruct

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

end
