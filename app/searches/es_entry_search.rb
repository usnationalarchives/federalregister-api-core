class EsEntrySearch < EsApplicationSearch

  def self.autocomplete(search_term)
    return [] unless search_term.present?
 
    host = Rails.application.credentials.dig(:elasticsearch, :host) || Settings.elasticsearch.host
    url = "#{host}/#{EntryRepository.index_name}/_search"
    response = Faraday.get(url) do |req|
      req.headers['Content-Type'] = 'application/json' # Set the content type if necessary
      payload = {
        "_source": ["search_term_completion"],
        "size": 10,
        "query": {
          "match": {
            "search_term_completion": {
              "query": search_term,
              "analyzer": "standard"
            }
          }
        }
      }
      req.body = payload.to_json 
    end
  
    JSON.parse(response.body).dig("hits","hits").map{|x| x.dig("_source","search_term_completion")}.uniq
  end

  class CFR < Struct.new(:title, :part)

    TITLE_MULTIPLIER = 100000

    def initialize(title,part)
      @errors = []

      self.title = title.to_s.strip
      self.part  = part.to_s.strip

      validate
    end

    def citation
      if part
        "#{title} CFR #{part}"
      else
        "#{title} CFR"
      end
    end

    def range_conditions
      title_int = title.to_i * TITLE_MULTIPLIER

      if part.blank?
        {
          gte: title_int,
          lt:  title_int + TITLE_MULTIPLIER,
        }
      elsif match = part.match(/(\d+)-(\d+)/)
        {
          gte: title_int + match[1].to_i,
          lte: title_int + match[2].to_i
        }
      else
        {
          gte: title_int + part.to_i,
          lte: title_int + part.to_i
        }
      end
    end

    def error_message
      @errors.to_sentence
    end

    private

    def validate
      unless (1..50).to_a.include?(title.to_i)
        @errors << "CFR title must be between 1 and 50"
      end

      unless part.blank? || part =~ /^\d+$/ || part =~ /^\d+ ?- ?\d+$/
        @errors << 'CFR part must be an integer or a range (eg "1" or "1-200")'
      end
    end
  end

  TYPES = [
    ['Rule',                  'RULE'    ],
    ['Proposed Rule',         'PRORULE' ],
    ['Notice',                'NOTICE'  ],
    ['Presidential Document', 'PRESDOCU']
  ]
  include Geokit::Geocoders

  attr_reader :type
  attr_accessor :type, :regulation_id_number, :prior_term

  define_filter :regulation_id_number, :label => "Unified Agenda", :phrase => true, :es_type => :es_match_query do |regulation_id_number|
    reg = RegulatoryPlan.find_by_regulation_id_number(regulation_id_number)
    ["RIN #{Array(regulation_id_number).first}", reg.try(:title).try(:strip)].join(' - ')
  end

  def regulatory_plan_title
    if @regulation_id_number.present?
      RegulatoryPlan.find_by_regulation_id_number(@regulation_id_number, :order => "issue DESC").try(:title)
    end
  end

  define_filter :agency_ids,
                :es_type => :with

  define_filter :agencies,
                :es_type => :with,
                :es_attribute => :agency_ids,
                :model_es_method => :id,
                :model_id_method=> :slug

  define_filter :citing_document_numbers,
                :es_type => :with,
                :es_attribute => :cited_entry_ids,
                :label => 'Citing document',
                :es_value_processor => Proc.new { |*document_numbers|
                  entries = Entry.select("id, document_number").where(:document_number => document_numbers.flatten)
                  missing_document_numbers = document_numbers.flatten - entries.map(&:document_number)

                  if missing_document_numbers.present?
                    raise EsApplicationSearch::InputError.new("#{missing_document_numbers.map(&:inspect).to_sentence} could not be found")
                  end

                  entry_id = entries.map(&:id).first
                  entry_id || -1 #NOTE: This filter is used when a subscription is created for a comment, though we don't publicly expose this search parameter in our API docs.  We return -1 here because elasticsearch expects an integer in the search options we build (and no entries have -1 for an id).  Returning an array here would require a significant, error-prone refactoring of the multi-value attribute handling in search infrastructure.
                } do |*document_numbers|
                  entries = Entry.select("id, citation").where(:document_number => document_numbers.flatten)

                  entries.map(&:citation).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end

  define_filter :document_numbers,
                :es_type => :with,
                :es_attribute => :document_number do |document_numbers|
                  document_numbers.flatten.map(&:inspect).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end

  define_filter :executive_order_numbers,
                :es_type => :with,
                :es_attribute => :executive_order_number do |eo_numbers|
                  eo_numbers.flatten.map(&:inspect).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end
          
  define_filter :president,
                :es_type => :with,
                :es_attribute => :president_id,
                :model_id_method=> :identifier,
                :model_es_method => :id,
                :model_label_method => :full_name

  define_filter :section_ids,
                :es_type => :with,
                :model_label_method => :title

  define_filter :volume,
                :es_type => :with,
                :name        => :volume

  define_filter :sections,
                :es_type => :with,
                :es_attribute => :section_ids,
                :model_label_method => :title,
                :model_es_method => :id,
                :model_id_method => :slug

  define_filter :topic_ids,
                :es_type => :with

  define_filter :topics,
                :es_type => :with,
                :es_attribute => :topic_ids,
                :model_label_method => :name,
                :model_es_method => :id,
                :model_id_method => :slug

  define_filter :type,
                :es_type => :with do |types|
                  types.map{|type| Entry::ENTRY_TYPES[type]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end

  define_filter :presidential_document_type_id,
                :es_type => :with

  define_filter :presidential_document_type,
                :es_type => :with,
                :es_attribute => :presidential_document_type_id,
                :model_es_method => :id,
                :model_id_method => :identifier

  define_filter :small_entity_ids,
                :es_type => :with,
                :label => "Small Entities Affected"

  define_filter :small_entities,
                :es_type => :with,
                :model_id_method => :identifier,
                :model_es_method => :id,
                :label => "Small Entities Affected"

  define_filter :docket_id,
                :es_type => :es_match_query,
                :phrase => true,
                :label => "Agency Docket" do |docket|
                  docket.join(', ')
                end

  define_filter :significant,
                :es_type => :with,
                :es_value_processor => Proc.new{|value| value == 1 },
                :label => "Significance" do
                  "Associated Unified Agenda Deemed Significant Under EO 12866"
                end

  define_filter :accepting_comments_on_regulations_dot_gov,
                :es_value_processor => Proc.new{|value| value == 1 },
                :es_type => :with,
                :label => "Regulations.gov" do
                  "Accepting Comments on Regulations.gov"
                end

  define_filter :correction,
                :es_value_processor => Proc.new{|value| value == 1 },
                :es_type => :with do |val|
                  case val
                  when '1', 1, true
                    "Original Document"
                  when '0', 0, false
                    "Correction"
                  end
                end


  define_place_filter :near,
                      :es_attribute => :place_ids

  define_date_filter :publication_date,
                     :label => "Publication Date"

  define_date_filter :signing_date,
                     :label => "Signing Date"

  define_date_filter :effective_date,
                     :label => "Effective Date"

  define_date_filter :comment_date,
                     :label => "Comment Close Date"

  attr_reader :cfr

  def cfr=(hsh)
    hsh = hsh.with_indifferent_access
    if hsh.present? && hsh.values.any?(&:present?)
      @cfr = CFR.new(hsh[:title], hsh[:part])

      if @cfr.error_message.blank?
        add_filter(
          :name => @cfr.citation,
          :condition => :cfr,
          :es_attribute => :cfr_affected_parts,
          :label => "Affected CFR Part",
          :es_type => :with_range,
          :range_conditions => @cfr.range_conditions
        )
      else
        @errors[:cfr] = @cfr.error_message
      end
    end
  end

  def start_page=(hsh)
    #This manual setter method is used so dynamic range conditions can be passed to the filter at runtime
    hsh = hsh.with_indifferent_access
    add_filter(
      :name             => "Start Page",
      :es_attribute => :start_page,
      :label            => "Start Page",
      :es_type      => :with_range,
      :range_conditions => hsh.fetch(:range_conditions)
    )
  end

  def end_page=(hsh)
    #This manual setter method is used so dynamic range conditions can be passed to the filter at runtime
    hsh = hsh.with_indifferent_access
    add_filter(
      :name             => "End Page",
      :es_attribute => :end_page,
      :label            => "End Page",
      :es_type      => :with_range,
      :range_conditions => hsh.fetch(:range_conditions)
    )
  end

  def model
    Entry
  end

  def find_options
    {
      :select => "id, title, publication_date, document_number, granule_class, document_file_path, abstract, start_page, end_page, citation, signing_date, executive_order_number, presidential_document_type_id",
      :sql => {
        :include => [:agencies, :agency_names],
      }
    }
  end

  def supported_orders
    %w(Relevant Newest Oldest)
  end

  def order_clause
    case @order
    when 'newest', 'date'
      "publication_date DESC, weighting DESC"
    when 'oldest'
      "publication_date ASC, weighting DESC"
    when 'executive_order_number'
      "executive_order_number ASC"
    when 'proclamation_number'
      "proclamation_number ASC"
    else
      @sort_mode = :expr
      'adjusted_weighting DESC'
    end


  end

  def sort_mode
    @sort_mode || :extended
  end

  def agency_facets
    self.aggregation_field = 'agency_ids'
    EsApplicationSearch::FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids, :identifier_attribute => :slug).all
  end
  memoize :agency_facets

  def section_facets
    self.aggregation_field = 'section_ids'
    EsApplicationSearch::FacetCalculator.new(:search => self, :model => Section, :facet_name => :section_ids, :name_attribute => :title, :identifier_attribute => :slug).all
  end
  memoize :section_facets

  def topic_facets
    self.aggregation_field = 'topic_ids'
    EsApplicationSearch::FacetCalculator.new(:search => self, :model => Topic, :facet_name => :topic_ids, :identifier_attribute => :slug).all
  end
  memoize :topic_facets

  def type_facets
    self.aggregation_field = 'type'
    EsApplicationSearch::FacetCalculator.new(:search => self, :facet_name => :type, :hash => Entry::ENTRY_TYPES).all().reject do |facet|
      ["UNKNOWN", "CORRECT"].include?(facet.value)
    end
  end
  memoize :type_facets

  def subtype_facets
    self.aggregation_field = 'presidential_document_type_id'
    EsApplicationSearch::FacetCalculator.new(
      :search => self,
      :model => PresidentialDocumentType,
      :facet_name => :presidential_document_type_id,
      :identifier_attribute => :identifier
    ).all
  end
  memoize :subtype_facets

  def date_distribution(options = {})
    klass = case options.delete(:period)
            when :daily
              EsEntrySearch::DateAggregator::Daily
            when :weekly
              EsEntrySearch::DateAggregator::Weekly
            when :monthly
              EsEntrySearch::DateAggregator::Monthly
            when :quarterly
              EsEntrySearch::DateAggregator::Quarterly
            when :yearly
              EsEntrySearch::DateAggregator::Yearly
            else
              raise "invalid :period specified; must be one of :daily, :weekly, :monthly, :quarterly or :yearly"
            end

    es_search                         = self
    es_search.date_histogram_interval = klass.date_histogram_interval

    klass.new(es_search, :with => with_for_facets)
  end

  def count_in_last_n_days(n)
    es_search_count(es_term,
      :with => with.merge(:publication_date => n.days.ago.to_time.midnight .. Time.current.midnight),
      :with_all => with_all,
      :without => without,
      :conditions => es_conditions,
      :match_mode => :extended
    )
  end

  def publication_year_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :facet_name => :publication, :hash => Entry::ENTRY_TYPES).all()
  end

  def publication_date_facets
    facets = [30,90,365].map do |n|
      value = n.days.ago.to_date.to_s
      ApplicationSearch::Facet.new(
        :value      => {:gte => value},
        :name       => "Past #{n} days",
        :count      => count_in_last_n_days(n),
        :condition  => :publication_date
      )
    end

    if facets.all?{|f| f.count == 0}
      return []
    else
      facets
    end
  end
  memoize :publication_date_facets

  def regulatory_plan
    if @regulation_id_number
      RegulatoryPlan.find_by_regulation_id_number(@regulation_id_number)
    end
  end
  memoize :regulatory_plan

  def matching_entry_citation
    if term.present?
      term.scan(/^\s*(\d+)\s*(?:F\.?R\.?|Fed\.?\s*Reg\.?)\s*([0-9,]+)\s*$/i) do |volume, page|
        return Citation.new(:citation_type => "FR", :part_1 => volume.to_i, :part_2 => page.gsub(/,/,'').to_i)
      end

      term.scan(/^\s*(?:E\s*O|Executive Order|E\.O\.)\s+([0-9,]+)\s*$/i) do |captures|
        return Citation.new(:citation_type => "EO", :part_1 => captures.first.gsub(/,/,'').to_i)
      end
    end

    return nil
  end

  def suggestion
    if !defined?(@suggestion)
      @suggestion = [
        EntrySearch::Suggestor::Agency,
        EntrySearch::Suggestor::Cfr,
        EntrySearch::Suggestor::Date,
        EntrySearch::Suggestor::EntryType,
        EntrySearch::Suggestor::RegulationIdNumber,
        EntrySearch::Suggestor::Spelling
      ].reduce(self) {|suggestion, suggestor| suggestor.new(suggestion).suggestion || suggestion }
      @suggestion = nil if @suggestion == self
    end

    @suggestion
  end

  def entry_with_document_number
    if term.present?
      return Entry.find_by_document_number(term)
    end
  end

  def summary
    if @term.blank? && filters.empty?
      "All Documents"
    else
      parts = filter_summary
      parts.unshift("matching '#{@term}'") if @term.present?

      'Documents ' + parts.to_sentence
    end
  end

  def filter_summary
    parts = []

    [
      ['published', :publication_date],
      ['signed', :signing_date],
      ['with an effective date', :effective_date],
      ['with a comment closing date', :comment_date],
      ['from', :agency_ids],
      ['from', :agencies],
      ['signed by', :president],
      ['of type', :type],
      ['of presidential document type', :presidential_document_type_id],
      ['of presidential document type', :presidential_document_type],
      ['filed under agency docket', :docket_id],
      ['whose', :significant],
      ['associated with', :regulation_id_number],
      ['affecting', :cfr],
      ['located', :near],
      ['in', :section_ids],
      ['in', :sections],
      ['about', :topic_ids],
      ['about', :topics],
      ['affecting Small', :small_entity_ids],
      ['affecting Small', :small_entities],
      ['citing', :citing_document_numbers]
    ].each do |term, filter_condition|
      relevant_filters = filters.select{|f| f.condition == filter_condition}

      unless relevant_filters.empty?
        parts << "#{term} #{relevant_filters.map(&:name).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', and ')}"
      end
    end

    parts
  end

  def results_for_date(date, args = {})
    date = ApplicationSearch::DateSelector.new(:is => date)
    results({:with => {:publication_date => date.es_value}, :per_page => 1000}.merge(args))
  end

  def public_inspection_search_possible?
    PublicInspectionDocumentSearch.valid_arguments?(
      :conditions => valid_conditions
    )
  end

  private

  def es_sort_order
    case @order
    when 'newest', 'date'
      [
        {publication_date: {order: "desc"}},
        {document_number: {order: "desc"}}, 
      ]
    when 'oldest'
      [
        {publication_date: {order: "asc"}},
        {document_number: {order: "asc"}}, 
      ]
    when 'executive_order_number'
      painless_script = <<-PAINLESS
        if (doc['executive_order_number'].empty) {
          return 0;
        }

        String digitsOnly = /[^0-9]/.matcher(doc['executive_order_number'].value).replaceAll('');
        Integer.parseInt(digitsOnly)
      PAINLESS
      [
        {
          "_script": {
            "type": "number",
            "script": {
              "source": painless_script,
              "lang": "painless"
            },
            "order": "asc"
          }
        },
        {executive_order_number: {order: "asc"}},
      ]
    when 'proclamation_number'
      [
        {executive_order_number: {order: "asc"}},
        {_score: {order: "desc"}}
      ]
    when 'id'
      [
        {id: {order: "asc"}},
      ]
    else
      [
        {_score: {order: "desc"}},
        {publication_date: {order: "desc"}},
      ]
    end
  end

  def es_base_must_conditions
    if Settings.feature_flags.include_pre_1994_docs && include_pre_1994_docs
      []
    else
      [
        exists: {
          field: "document_number"
        },
      ]
    end
  end

  def highlight_fields
    {
      "full_text" => {
        matched_fields: ["full_text", "full_text.exact"],
        fragment_size: 550,
        number_of_fragments: 1,
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
    $entry_repository
  end

  def es_fields_with_boosts
    ['title^2.5', 'full_text^1.25', 'agency_name^1', 'abstract^2', 'docket_id^1', 'regulation_id_number^1']
  end

end
