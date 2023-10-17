class EsPublicInspectionDocumentSearchResult < EsSearchResult

  def page_views
    start_date = Settings.app.public_inspection_documents.page_view_start_date
    start_date = Date.parse(start_date) if start_date

    if filed_at && start_date && (filed_at.to_date >= start_date)
      BatchLoader.for(document_number).batch do |document_numbers, loader|
        PageViewCount.batch_count_for(document_numbers, PageViewType::PUBLIC_INSPECTION_DOCUMENT).each do |document_number, details|
          loader.call(document_number, details)
        end
      end
    end
  end

  def slug
    clean_title = title.downcase.gsub(/[^a-z0-9& -]+/,'').gsub(/&/, 'and')
    slug = truncate_words(clean_title, :length => 100, :omission => '')
    slug.gsub(/ /,'-')
  end

  def type
    Entry::ENTRY_TYPES[self['type']]
  end

end
