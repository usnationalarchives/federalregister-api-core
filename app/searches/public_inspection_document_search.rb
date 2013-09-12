class PublicInspectionDocumentSearch < ApplicationSearch
  define_filter :agency_ids,
                :sphinx_type => :with

  define_filter :agencies,
                :sphinx_attribute => :agency_ids,
                :sphinx_type => :with,
                :model_id_method => :slug

  define_filter :type,
                :sphinx_type => :with, :crc32_encode => true do |types|
                  types.map{|type| Entry::ENTRY_TYPES[type]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end

  define_filter :docket_id,
                :phrase => true,
                :label => "Agency Docket" do |docket|
                  docket
                end 
  define_filter(:document_numbers,
                :sphinx_type => :with,
                :sphinx_attribute => :document_number,
                :sphinx_value_processor => Proc.new{|*document_numbers| document_numbers.flatten.map{|x| x.to_s.to_crc32}}) do |*document_numbers|
                  document_numbers.flatten.map(&:inspect).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end
  define_filter :special_filing,
                :sphinx_type => :with,
                :label => "Filing Type" do |type|
                  case type
                  when 1, '1', ['1']
                    'Special Filing'
                  else
                    'Regular Filing'
                  end
                end
  
  def agency_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets
  
  def type_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :facet_name => :type, :hash => Entry::ENTRY_TYPES).all().reject do |facet|
      ["UNKNOWN", "CORRECT"].include?(facet.value)
    end
  end
  memoize :type_facets

  def self.new_if_possible(args)
    if valid_arguments?(args)
      new(args)
    end
  end

  def self.valid_arguments?(args)
    args[:conditions] ||= {}
    (args[:conditions].keys.map(&:to_sym)- [:term, :docket_id, :agency_ids, :type]).size == 0
  end

  def public_inspection_search_possible?
    true
  end

  def model
    PublicInspectionDocument
  end
  
  def find_options
    {
      :select => "id, title, pdf_file_name, pdf_file_size, num_pages, toc_subject, toc_doc, publication_date, filed_at, document_number, granule_class, editorial_note",
      :include => :agencies,
    }
  end
  
  def supported_orders
    %w(Relevant)
  end
  
  def order_clause
    "@relevance DESC, filed_at DESC"
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
      ['categorized as', :special_filing],
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
