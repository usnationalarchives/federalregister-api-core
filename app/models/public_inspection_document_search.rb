class PublicInspectionDocumentSearch < ApplicationSearch
  define_filter :agency_ids,  :sphinx_type => :with
  define_filter :type,        :sphinx_type => :with, :crc32_encode => true do |types|
    types.map{|type| Entry::ENTRY_TYPES[type]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
  end
  
  define_date_filter :publication_date, :label => "Publication Date"
  
  def model
    PublicInspectionDocument
  end
  
  def find_options
    {
      :select => "id, title, toc_subject, toc_doc, publication_date, document_number, granule_class",
      :include => :agencies,
    }
  end
  
  def supported_orders
    %w(Relevant Newest Oldest)
  end
  
  def order_clause
    case @order
    when 'newest'
      "publication_date DESC, @relevance DESC"
    when 'oldest'
      "publication_date ASC, @relevance DESC"
    else
      "@relevance DESC, publication_date DESC"
    end
  end

  def summary
    if @term.blank? && filters.empty?
      "All Public Inspection Documents"
    else
      parts = filter_summary
      parts.unshift("matching '#{@term}'") if @term.present?
      
      'Public Inspection Documents ' + parts.to_sentence
    end
  end
  
  def filter_summary
    parts = []
    
    [
      ['published', :publication_date],
      ['from', :agency_ids],
      ['of type', :type],
      ['filed under agency docket', :docket_id],
    ].each do |term, filter_condition|
      relevant_filters = filters.select{|f| f.condition == filter_condition}
    
      unless relevant_filters.empty?
        parts << "#{term} #{relevant_filters.map(&:name).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', and ')}"
      end
    end
    
    parts
  end
  
  private
  
  def set_defaults(options)
    @within = 25
    @order = options[:order] || 'relevant'
  end
end
