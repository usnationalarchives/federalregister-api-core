class EsPublicInspectionDocumentSearch < EsApplicationSearch

  define_filter :agency_ids,
                :sphinx_type => :with

  define_filter :agencies, #ie slug-based search
                :sphinx_attribute => :agency_ids,
                :sphinx_type => :with,
                :model_id_method => :slug,
                :model_sphinx_method => :id


  define_filter :type,
                :sphinx_type => :with do |types|
                  types.map{|type| Entry::ENTRY_TYPES[type]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end

  define_filter :docket_id,
                :sphinx_type => :es_match_query,
                :label => "Agency Docket" do |docket|
                  docket.first
                end
  define_filter :document_numbers,
                :sphinx_type => :with,
                :sphinx_attribute => :document_number do |*document_numbers|
                  document_numbers.flatten.map(&:inspect).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end
  define_filter :special_filing,
                :sphinx_type => :with,
                :es_value_processor => Proc.new{|value| value == 1 },
                :label => "Filing Type" do |type|
                  case type
                  when 1, '1', ['1']
                    'Special Filing'
                  else
                    'Regular Filing'
                  end
                end

  define_date_filter :filed_at,
                     :label => "Filing Date"

  def agency_facets
    self.aggregation_field = 'agency_ids'
    EsApplicationSearch::FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets

  def agencies_facets
    self.aggregation_field = 'agency_ids'
    EsApplicationSearch::FacetCalculator.new(
      :search => self,
      :model => Agency,
      :facet_name => :agency_ids,
      :identifier_attribute => :slug
    ).all
  end
  memoize :agencies_facets

  def type_facets
    self.aggregation_field = 'type.keyword'
    EsApplicationSearch::FacetCalculator.new(
      :search => self,
      :facet_name => :type,
      :hash => Entry::ENTRY_TYPES
    ).all().reject do |facet|
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
      :select => "id, title, publication_date, document_number, granule_class, document_file_path, abstract, start_page, end_page, citation, signing_date, executive_order_number, presidential_document_type_id, raw_text_updated_at",
      :include => :agencies,
    }
  end

  def supported_orders
    %w(Relevant)
  end

  def order_clause
    "filed_at DESC"
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
      ['from', :agencies],
      ['of type', :type],
      ['categorized as', :special_filing],
      ['filed under agency docket', :docket_id],
      ['filed at', :filing_date],
    ].each do |term, filter_condition|
      relevant_filters = filters.select{|f| f.condition == filter_condition}

      unless relevant_filters.empty?
        parts << "#{term} #{relevant_filters.map(&:name).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', and ')}"
      end
    end

    parts
  end

  # def results
  #   # join docket_numbers
  #   # join public_inspection_issues

  #   model_scope = model.
  #     includes(:docket_numbers).
  #     includes(:public_inspection_issues)

  #   super(model_scope: model_scope)
  # end

  private

  def es_sort_order
    [
      {filed_at: {order: "desc"}},
      {_score: {order: "desc"}}
    ]
  end

  def highlight_fields
    #NOTE: It is necessary to include the .exact fields or no excerpts will be returned for queries that include double quotes.
    {
      "title" => {
        matched_fields: ["title", "title.exact"],
        fragment_size: 150,
        number_of_fragments: 3,
        order: 'score',
        type: 'fvh',
      },
      "full_text" => {
        matched_fields: ["full_text", "full_text.exact"],
        fragment_size: 150,
        number_of_fragments: 3,
        order: 'score',
        type: 'fvh',
      }
    }
  end

  def set_defaults(options)
    @within = 25
    @order = options[:order] || 'relevant'
  end

  def repository
    $public_inspection_document_repository
  end

  def es_fields_with_boosts
    ['title^2.5', 'full_text^1.25', 'agency_name^1','docket_id^1']
  end

end
