class EsEntrySearchResult < EsSearchResult

  def docket_id
    # Ensure interface matches with historical EntryApiRepresentation
    self['docket_id'].uniq.first
  end

  def docket_ids
    # Ensure interface matches with historical EntryApiRepresentation
    self['docket_id']
  end

  def page_views
    BatchLoader.for(document_number).batch do |document_numbers, loader|
      PageViewCount.batch_count_for(document_numbers, PageViewType::DOCUMENT).each do |document_number, details|
        loader.call(document_number, details) 
      end
    end
  end

  def type
    entry_type #NOTE: The serializer/ES-stored "type" attribute is different than the "type" field returned in API requests, hence the override here.
  end

end
