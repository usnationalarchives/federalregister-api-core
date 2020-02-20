class EsPublicInspectionDocumentSearch < EsApplicationSearch
  define_filter :agency_ids,
                :sphinx_type => :with

  define_filter :agencies,
                :sphinx_attribute => :agency_ids,
                :sphinx_type => :with,
                :model_id_method => :slug,
                :model_sphinx_method => :id

  define_filter :type,
                :sphinx_type => :with do |types|
                  types.map{|type| Entry::ENTRY_TYPES[type]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end

  define_filter :docket_id,
                :sphinx_type => :with,
                :label => "Agency Docket" do |docket|
                  docket.first
                end
  define_filter(:document_numbers,
                :sphinx_type => :with,
                :sphinx_attribute => :document_number)
                #:es_value_processor => Proc.new{|*document_numbers| document_numbers})
                #:sphinx_value_processor => Proc.new{|*document_numbers| document_numbers.flatten.map{|x| Zlib.crc32(x.to_s) }}) do |*document_numbers|
                #  document_numbers.flatten.map(&:inspect).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                #end
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
    ApplicationSearch::FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets

  def agencies_facets
    ApplicationSearch::FacetCalculator.new(
      :search => self,
      :model => Agency,
      :facet_name => :agency_ids,
      :identifier_attribute => :slug
    ).all
  end
  memoize :agencies_facets

  def type_facets
    ApplicationSearch::FacetCalculator.new(
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
      :select => "*, weight() as weighting",
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

  def results
    # join docket_numbers
    # join public_inspection_issues

    model_scope = model.
      includes(:docket_numbers).
      includes(:public_inspection_issues)

    super(model_scope: model_scope)
  end

  private

  def set_defaults(options)
    @within = 25
    @order = options[:order] || 'relevant'
  end

  def repository
    $public_inspection_document_repository
  end
end
