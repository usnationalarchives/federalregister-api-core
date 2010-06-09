class ApplicationSearch
  extend ActiveSupport::Memoizable
  
  class Filter
    attr_reader :value, :condition, :label, :sphinx_type, :sphinx_attribute, :sphinx_value
    def initialize(options)
      @value        = options[:value]
      @name         = options[:name]
      @name_definer = options[:name_definer]
      @condition    = options[:condition]
      @sphinx_attribute = options[:sphinx_attribute] || @condition
      @sphinx_value = options[:phrase] ? "\"#{options[:value]}\"" : options[:value]
      @sphinx_type  = options[:sphinx_type] || :conditions
      @label        = options[:label] || @condition.to_s.singularize.humanize
    end
    
    def name
      @name ||= @name_definer.call(value)
    end
  end
  
  class Facet
    attr_reader :value, :name, :condition, :count, :on

    def initialize(options)
      @value      = options[:value]
      @name       = options[:name]
      @condition  = options[:condition]
      @count      = options[:count]
      @on         = options[:on]
    end
    
    def on?
      @on
    end
  end
  
  class FacetCalculator
    def initialize(options)
      @search = options[:search]
      @model = options[:model]
      @facet_name = options[:facet_name]
      @name_attribute = options[:name_attribute] || :name
    end
    
    def raw_facets
      sphinx_search = ThinkingSphinx::Search.new(@search.term,
        :with => @search.with.except(@facet_name),
        :conditions => @search.conditions,
        :match_mode => :extended,
        :classes => [@search.model]
      )
      
      client = sphinx_search.send(:client)
      client.group_function = :attr
      client.group_by = @facet_name.to_s
      client.limit = 5000
      
      query = sphinx_search.send(:query)
      result = client.query(query, sphinx_search.send(:indexes))[:matches].map{|m| [m[:attributes]["@groupby"], m[:attributes]["@count"]]}
    end
    
    def all
      id_to_name = @model.find_as_hash(:select => "id, #{@name_attribute} AS name")#, :conditions => {:id => raw_facets.keys})
      search_value_for_this_facet = @search.send(@facet_name)
      
      facets = raw_facets.reverse.reject{|id, count| id == 0}.map do |id, count|
        Facet.new(
          :value      => id, 
          :name       => id_to_name[id.to_s],
          :count      => count,
          :on         => id.to_s == search_value_for_this_facet.to_s,
          :condition  => @facet_name
        )
      end
      
      facets.sort_by{|f| [0-f.count, f.name]}
    end
  end
  
  attr_accessor :term
  attr_reader :errors, :filters
  
  def self.define_filter(filter_name, options = {}, &name_definer)
    attr_reader filter_name
    
    name_definer ||= Proc.new{|id| filter_name.to_s.sub(/_ids?$/,'').classify.constantize.find_by_id(id).try(:name) }
    
    define_method "#{filter_name}=" do |val|
      if val.present?
        instance_variable_set("@#{filter_name}", val)
        add_filter options.merge(:value => val, :condition => filter_name, :name_definer => name_definer)
      end
    end
  end
  
  def initialize(options = {})
    options.symbolize_keys!
    @errors = []
    @filters = []
    
    # Set some defaults...
    @per_page = 20
    @page = options[:page] || 1
    
    set_defaults(options)
    
    self.conditions = options[:conditions] || {}
  end
  
  def conditions=(conditions)
    conditions.to_a.reverse.each do |attr, val|
      self.send("#{attr}=", val)
    end
  end
  
  def add_filter(options)
    @filters << Filter.new(options)
  end
  
  def valid?
    @errors.empty?
  end
  
  def blank?
    [with, conditions, term].all?(&:blank?)
  end
  
  def conditions
    conditions = {}
    @filters.select{|f| f.sphinx_type == :conditions }.each do |filter|
      conditions[filter.sphinx_attribute] = filter.sphinx_value
    end
    
    conditions
  end
  
  def with
    with = {}
    @filters.select{|f| f.sphinx_type == :with }.each do |filter|
      with[filter.sphinx_attribute] = filter.sphinx_value
    end
    with
  end
  
  def results
    unless defined?(@results)
      @results = model.search(@term,
        {
          :page => @page,
          :per_page => @per_page,
          :order => order_clause,
          :with => with,
          :conditions => conditions,
          :match_mode => :extended,
          :sort_mode => :extended
        }.merge(find_options)
      )
      
      # TODO: FIXME: Ugly hack to get total pages to be within bounds
      if @results && @results.total_pages > 50
        def @results.total_pages
          50
        end
      end
    end
    @results
  end
  
  def order_clause
    "@relevance DESC"
  end
  
  def find_options
    {}
  end
  
  def count
    model.search_count(@term, :match_mode => :extended)
  end
  
  def entry_count
    EntrySearch.new(:conditions => {:term => @term}).count
  end
  
  def regulatory_plan_count
    RegulatoryPlanSearch.new(:conditions => {:term => @term}).count
  end
end