class EntrySearch < ApplicationSearch
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
    
    def sphinx_citation
      title_int = title.to_i * TITLE_MULTIPLIER
      if part.blank?
        title_int ... title_int + TITLE_MULTIPLIER
      elsif match = part.match(/(\d+)-(\d+)/)
        title_int + match[1].to_i .. title_int + match[2].to_i
      else
        title_int + part.to_i
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
  
  define_filter :regulation_id_number, :label => "Unified Agenda", :phrase => true do |regulation_id_number|
    reg = RegulatoryPlan.find_by_regulation_id_number(regulation_id_number)
    ["RIN #{regulation_id_number}", reg.try(:title)].join(' - ')
  end
  
  def regulatory_plan_title
    if @regulation_id_number.present?
      RegulatoryPlan.find_by_regulation_id_number(@regulation_id_number, :order => "issue DESC").try(:title)
    end
  end
  
  define_filter :agency_ids,
                :sphinx_type => :with

  define_filter :agencies,
                :sphinx_type => :with,
                :sphinx_attribute => :agency_ids,
                :model_sphinx_method => :id,
                :model_id_method=> :slug
  define_filter(:citing_document_numbers,
                :sphinx_type => :with,
                :sphinx_attribute => :cited_entry_ids,
                :sphinx_value_processor => Proc.new { |*document_numbers|
                  entries = Entry.all(:select => "id, document_number", :conditions => {:document_number => document_numbers.flatten})
                  missing_document_numbers = entries.map(&:document_number) - document_numbers.flatten

                  if missing_document_numbers.present?
                    raise ApplicationSearch::InputError.new("#{missing_document_numbers.map(&:inspect).to_sentence} could not be found")
                  end

                  entries.map(&:id)
                }) do |*document_numbers|
                  document_numbers.flatten.map(&:inspect).to_sentence
                end

  define_filter(:document_numbers,
                :sphinx_type => :with,
                :sphinx_attribute => :document_number,
                :sphinx_value_processor => Proc.new{|*document_numbers| document_numbers.flatten.map{|x| x.to_s.to_crc32}}) do |*document_numbers|
                  document_numbers.flatten.map(&:inspect).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end
  define_filter :president,
                :sphinx_type => :with,
                :sphinx_attribute => :president_id,
                :model_id_method=> :identifier,
                :model_sphinx_method => :id,
                :model_label_method => :full_name

  define_filter :section_ids,
                :sphinx_type => :with_all,
                :model_label_method => :title

  define_filter :sections,
                :sphinx_type => :with_all,
                :sphinx_attribute => :section_ids,
                :model_label_method => :title,
                :model_id_attribute => :slug

  define_filter :topic_ids,
                :sphinx_type => :with_all

  define_filter :type,
                :sphinx_type => :with,
                :crc32_encode => true do |types|
                  types.map{|type| Entry::ENTRY_TYPES[type]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
                end
  
  define_filter :presidential_document_type_id,
                :sphinx_type => :with

  define_filter :presidential_document_type,
                :sphinx_type => :with,
                :sphinx_attribute => :presidential_document_type_id,
                :model_sphinx_method => :id,
                :model_id_method => :identifier

  define_filter :small_entity_ids,
                :sphinx_type => :with,
                :label => "Small Entities Affected"
  
  define_filter :small_entities,
                :sphinx_type => :with,
                :model_id_method => :identifier,
                :model_sphinx_method => :id,
                :label => "Small Entities Affected"

  define_filter :docket_id,
                :phrase => true,
                :label => "Agency Docket" do |docket|
                  docket
                end
  
  define_filter :significant,
                :sphinx_type => :with,
                :label => "Significance" do 
                  "Associated Unified Agenda Deemed Significant Under EO 12866"
                end

  define_filter :correction,
                :sphinx_type => :with do |val|
                  case val
                  when '1', 1, true
                    "Original Document"
                  when '0', 0, false
                    "Correction"
                  end
                end


  define_place_filter :near,
                      :sphinx_attribute => :place_ids

  define_date_filter :publication_date,
                     :label => "Publication Date"

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
          :value => @cfr.sphinx_citation,
          :name => @cfr.citation,
          :condition => :cfr,
          :sphinx_attribute => :cfr_affected_parts,
          :label => "Affected CFR Part",
          :sphinx_type => :with
        )
      else
        @errors[:cfr] = @cfr.error_message
      end
    end
  end
  
  def model
    Entry
  end
  
  def find_options
    {
      :select => "id, title, publication_date, document_number, granule_class, document_file_path, abstract, start_page, end_page, citation, signing_date, executive_order_number, presidential_document_type_id",
      :include => [:agencies, :agency_names],
    }
  end
  
  def supported_orders
    %w(Relevant Newest Oldest)
  end
  
  def order_clause
    case @order
    when 'newest', 'date'
      "publication_date DESC, @relevance DESC"
    when 'oldest'
      "publication_date ASC, @relevance DESC"
    when 'executive_order_number'
      "executive_order_number ASC"
    else
      @sort_mode = :expr
      "@weight * 1/LOG2( (((NOW()+#{5.days}) - publication_date) / #{1.year} / 3)+2 )"
    end
  end

  def sort_mode
    @sort_mode || :extended
  end
  
  def agency_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets
  
  def section_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :model => Section, :facet_name => :section_ids, :name_attribute => :title).all
  end
  memoize :section_facets
  
  def topic_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :model => Topic, :facet_name => :topic_ids).all
  end
  memoize :topic_facets
  
  def type_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :facet_name => :type, :hash => Entry::ENTRY_TYPES).all().reject do |facet|
      ["UNKNOWN", "CORRECT"].include?(facet.value)
    end
  end
  memoize :type_facets
  
  def date_distribution(options = {})
    options[:since] ||= Date.parse('1994-01-01')
    sphinx_search = ThinkingSphinx::Search.new(sphinx_term,
      :with => with.merge(:publication_date => options[:since].to_time .. 1.week.from_now),
      :with_all => with_all,
      :without => without,
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
    sphinx_search_count(sphinx_term,
      :with => with.merge(:publication_date => n.days.ago.to_time.midnight .. Time.current.midnight),
      :with_all => with_all,
      :without => without,
      :conditions => sphinx_conditions,
      :match_mode => :extended
    )
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

      term.scan(/^\s*(?:EO|Executive Order|E\.O\.)\s+([0-9,]+)\s*$/i) do |captures|
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
      ['affecting Small', :small_entity_ids],
      ['affecting Small', :small_entities]
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
    results({:with => {:publication_date => date.sphinx_value}, :per_page => 1000}.merge(args))
  end

  def public_inspection_search_possible?
    PublicInspectionDocumentSearch.valid_arguments?(
      :conditions => valid_conditions
    )
  end

  private
  
  def set_defaults(options)
    @within = 25
    @order = options[:order] || 'relevant'
  end
end
