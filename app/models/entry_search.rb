class EntrySearch < ApplicationSearch
  class CFR < Struct.new(:title,:part)
    def citation
      "#{title} CFR #{part}"
    end
    
    def sphinx_citation
      title.to_i * 100000 + part.to_i
    end
  end
  
  class DateSelector
    attr_accessor :is, :gte, :lte, :year
    attr_reader :sphinx_value, :filter_name
    
    def initialize(hsh)
      @is = hsh[:is]
      @gte = hsh[:gte]
      @lte = hsh[:lte]
      @year = hsh[:year].try(:to_i)
      
      if @is.present?
        date = Date.parse(@is)
        @sphinx_value = date.to_time.utc.beginning_of_day.to_i .. date.to_time.utc.end_of_day.to_i
        @filter_name = "on #{date}"
      elsif @year.present?
        date = Date.parse("#{@year}-01-01")
        @sphinx_value = date.to_time.utc.beginning_of_day.to_i .. date.end_of_year.to_time.utc.end_of_day.to_i
        @filter_name = "in #{@year}"
      else
        start_date = if hsh[:gte].present?
                       Date.parse(hsh[:gte])
                     else
                       Date.parse('1994-01-01')
                     end
        end_date = if hsh[:lte].present?
                     Date.parse(hsh[:lte])
                   else
                     Issue.current.try(:publication_date) || Date.current
                   end
        @sphinx_value = start_date.to_time.utc.beginning_of_day.to_i .. end_date.to_time.utc.end_of_day.to_i
        @filter_name = "from #{start_date} to #{end_date}"
      end
    end
  end
  
  TYPES = [
    ['Rule',                  'RULE'    ], 
    ['Proposed Rule',         'PRORULE' ], 
    ['Notice',                'NOTICE'  ], 
    ['Presidential Document', 'PRESDOCU'], 
    ['Sunshine Act Document', 'SUNSHINE']
  ]
  include Geokit::Geocoders
  
  attr_reader :type
  attr_accessor :type, :regulation_id_number
  
  define_filter :regulation_id_number, :label => "Unified Agenda", :phrase => true do |regulation_id_number|
    reg = RegulatoryPlan.find_by_regulation_id_number(regulation_id_number)
    ["RIN #{regulation_id_number}", reg.try(:title)].join(' - ')
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
  
  define_filter :significant, :sphinx_type => :with, :label => "Signficance" do 
    "Associated Unified Agenda Deemed Significant by OIRA"
  end
  
  define_place_filter :place_ids
  attr_reader :cfr, :publication_date

  def publication_date=(hsh)
    # TODO :error handling
    if hsh.values.any?(&:present?)
      @publication_date = DateSelector.new(hsh)
      add_filter(
        :value => @publication_date.sphinx_value,
        :name => @publication_date.filter_name,
        :condition => :date,
        :label => "Published",
        :sphinx_type => :conditions,
        :sphinx_attribute => :publication_date
      )
    end
  end
  
  def cfr=(hsh)
    if hsh.present? && hsh.values.present?
      @cfr = CFR.new(hsh[:title], hsh[:part])
      
      # TODO: error handling
      if @cfr.title.present? && @cfr.part.present?
        add_filter(
          :value => @cfr.sphinx_citation,
          :name => @cfr.citation,
          :sphinx_attribute => :cfr_affected_parts,
          :label => "Affected CFR Part",
          :sphinx_type => :with
        )
      end
    end
  end
  
  def model
    Entry
  end
  
  def find_options
    {
      :select => "id, title, publication_date, document_number, document_file_path, abstract",
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
    raw_facets = Entry.facets(term,
      :with => with,
      :with_all => with_all,
      :conditions => sphinx_conditions,
      :match_mode => :extended,
      :facets => [:type]
    )[:type]
    
    search_value_for_this_facet = self.type
    facets = raw_facets.to_a.reverse.reject{|id, count| id == 'UNKNOWN'}.map do |id, count|
      Facet.new(
        :value      => id, 
        :name       => Entry::ENTRY_TYPES[id],
        :count      => count,
        :on         => id.to_s == search_value_for_this_facet.to_s,
        :condition  => :type
      )
    end
  end
  memoize :type_facets
  
  def date_distribution
    sphinx_search = ThinkingSphinx::Search.new(term,
      :with => with,
      :with_all => with_all,
      :conditions => sphinx_conditions,
      :match_mode => :extended
    )
    
    client = sphinx_search.send(:client)
    client.group_function = :month
    client.group_by = "publication_date"
    client.limit = 5000
    
    query = sphinx_search.send(:query)
    dist = {}
    client.query(query, '*')[:matches].each{|m| dist[m[:attributes]["@groupby"].to_s] = m[:attributes]["@count"] }
    
    (1994..Time.current.to_date.year).each do |year|
      (1..12).each do |month|
        dist[sprintf("%d%02d",year, month)] ||= 0
      end
    end
    
    dist
  end
  
  def count_in_last_n_days(n)
    model.search_count(@term,
      :with => with.merge(:publication_date => n.days.ago.to_time.midnight .. Time.current.midnight),
      :with_all => with_all,
      :conditions => sphinx_conditions,
      :match_mode => :extended
    )
  end
  
  def date_facets
    [30,90,365].map do |n|
      value = n.days.ago.to_date.to_s
      Facet.new(
        :value      => value,
        :name       => "Past #{n} days",
        :count      => count_in_last_n_days(n),
        :on         => start_date == value,
        :condition  => :start_date
      )
    end
  end
  memoize :date_facets
  
  def regulatory_plan
    if @regulation_id_number
      RegulatoryPlan.find_by_regulation_id_number(@regulation_id_number)
    end
  end
  memoize :regulatory_plan
  
  def matching_entry_citation
    if term.present?
      term.scan(/^\s*(\d+)\s*F\.?R\.?\s*(\d+)\s*$/) do |volume, page|
        return Citation.new(:citation_type => "FR", :part_1 => volume.to_i, :part_2 => page.to_i)
      end
    end
    
    return nil
  end
  
  def entry_with_document_number
    if term.present?
      return Entry.find_by_document_number(term)
    end
  end
  
  private
  
  def set_defaults(options)
    @within = '25'
    @order = options[:order] || 'relevant'
  end
end