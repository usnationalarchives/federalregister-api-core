class EntrySearch < ApplicationSearch
  class CFR < Struct.new(:title,:part)
    TITLE_MULTIPLIER = 100000
    def citation
      if part
        "#{title} CFR #{part}"
      else
        "#{title} CFR"
      end
    end
    
    def sphinx_citation
      title_int =  title.to_s.to_i * TITLE_MULTIPLIER
      if part
        title_int + part.to_s.to_i
      else
        title_int ... title_int + TITLE_MULTIPLIER
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
  
  define_filter :regulation_id_number, :label => "Unified Agenda", :phrase => true do |regulation_id_number|
    reg = RegulatoryPlan.find_by_regulation_id_number(regulation_id_number)
    ["RIN #{regulation_id_number}", reg.try(:title)].join(' - ')
  end
  
  def regulatory_plan_title
    if @regulation_id_number.present?
      RegulatoryPlan.find_by_regulation_id_number(@regulation_id_number, :order => "issue DESC").try(:title)
    end
  end
  
  define_filter :agency_ids,  :sphinx_type => :with
  define_filter :section_ids, :sphinx_type => :with_all do |section_id|
    Section.find_by_id(section_id).try(:title)
  end
  define_filter :topic_ids,   :sphinx_type => :with_all
  define_filter :type,        :sphinx_type => :with, :crc32_encode => true do |types|
    types.map{|type| Entry::ENTRY_TYPES[type]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
  end
  
  define_filter :docket_id, :phrase => true, :label => "Agency Docket" do |docket|
    docket
  end
  
  define_filter :significant, :sphinx_type => :with, :label => "Significance" do 
    "Associated Unified Agenda Deemed Significant Under EO 12866"
  end
  
  define_place_filter :near, :sphinx_attribute => :place_ids
  define_date_filter :publication_date, :label => "Publication Date"
  define_date_filter :effective_date, :label => "Effective Date"
  define_date_filter :comment_date, :label => "Comment Date"
  
  attr_reader :cfr
  
  def cfr=(hsh)
    hsh = hsh.with_indifferent_access
    if hsh.present? && hsh.values.any?(&:present?)
      @cfr = CFR.new(hsh[:title], hsh[:part])
      
      if @cfr.title.present?
        add_filter(
          :value => @cfr.sphinx_citation,
          :name => @cfr.citation,
          :condition => :cfr,
          :sphinx_attribute => :cfr_affected_parts,
          :label => "Affected CFR Part",
          :sphinx_type => :with
        )
      else
        @errors[:cfr] = "You must provide at least a CFR title"
      end
    end
  end
  
  def model
    Entry
  end
  
  def find_options
    {
      :select => "id, title, publication_date, document_number, granule_class, document_file_path, abstract, length, start_page, end_page",
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
  
  def agency_facets
    FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets
  
  def section_facets
    FacetCalculator.new(:search => self, :model => Section, :facet_name => :section_ids, :name_attribute => :title).all
  end
  memoize :section_facets
  
  def topic_facets
    FacetCalculator.new(:search => self, :model => Topic, :facet_name => :topic_ids).all
  end
  memoize :topic_facets
  
  def type_facets
    FacetCalculator.new(:search => self, :facet_name => :type, :hash => Entry::ENTRY_TYPES).all().reject do |facet|
      ["UNKNOWN", "CORRECT"].include?(facet.value)
    end
  end
  memoize :type_facets
  
  def date_distribution(options = {})
    options[:since] ||= Date.parse('1994-01-01')
    sphinx_search = ThinkingSphinx::Search.new(term,
      :with => with.merge(:publication_date => options[:since].to_time .. 1.week.from_now),
      :with_all => with_all,
      :conditions => sphinx_conditions,
      :match_mode => :extended
    )
    klass = case options.delete(:period)
            when :weekly
              EntrySearch::DateAggregator::Weekly
            when :monthly
              EntrySearch::DateAggregator::Monthly
            when :quarterly
              EntrySearch::DateAggregator::Quarterly
            else
              raise "invalid :period specified; must be one of :weekly, :monthly, or :quarterly"
            end
    distribution = klass.new(sphinx_search, options)
    distribution.results
  end

  def count_in_last_n_days(n)
    model.search_count(@term,
      :with => with.merge(:publication_date => n.days.ago.to_time.midnight .. Time.current.midnight),
      :with_all => with_all,
      :conditions => sphinx_conditions,
      :match_mode => :extended
    )
  end
  
  def publication_date_facets
    facets = [30,90,365].map do |n|
      value = n.days.ago.to_date.to_s
      Facet.new(
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
      term.scan(/^\s*(\d+)\s*(?:F\.?R\.?|Fed\.?\s*Reg\.?)\s*(\d+)\s*$/i) do |volume, page|
        return Citation.new(:citation_type => "FR", :part_1 => volume.to_i, :part_2 => page.to_i)
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
        EntrySearch::Suggestor::HyphenatedIdentifier,
        EntrySearch::Suggestor::Spelling,
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
      "All Articles"
    else
      parts = filter_summary
      parts.unshift("matching '#{@term}'") if @term.present?
      
      'Articles ' + parts.to_sentence
    end
  end
  
  def filter_summary
    parts = []
    
    [
      ['published', :publication_date],
      ['with an effective date', :effective_date],
      ['from', :agency_ids],
      ['of type', :type],
      ['filed under agency docket', :docket_id],
      ['whose', :significant],
      ['associated with', :regulation_id_number],
      ['affecting', :cfr],
      ['located', :near],
      ['in', :section_ids],
      ['about', :topic_ids]
    ].each do |term, filter_condition|
      relevant_filters = filters.select{|f| f.condition == filter_condition}
    
      unless relevant_filters.empty?
        parts << "#{term} #{relevant_filters.map(&:name).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', and ')}"
      end
    end
    
    parts
  end
  
  def results_for_date(date, args = {})
    date = DateSelector.new(:is => date)
    results({:with => {:publication_date => date.sphinx_value}, :per_page => 1000}.merge(args))
  end
  
  private
  
  def set_defaults(options)
    @within = 25
    @order = options[:order] || 'relevant'
  end
end
