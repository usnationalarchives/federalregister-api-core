class EntrySearch
  include Geokit::Geocoders
  extend ActiveSupport::Memoizable
  
  class Facet
    attr_reader :id, :name, :count, :on
    def initialize(id, name, count, on)
      @id = id
      @name = name
      @count = count
      @on = on
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
      Entry.facets(@search.term,
        :with => @search.with.except(@facet_name),
        :conditions => @search.conditions,
        :match_mode => :extended,
        :facets => [@facet_name]
      )[@facet_name]
    end
    
    def all
      id_to_name = @model.find_as_hash(:select => "id, #{@name_attribute} AS name", :conditions => {:id => raw_facets.keys})
      
      search_value_for_this_facet = @search.send(@facet_name)
      facets = raw_facets.to_a.reverse.reject{|id, count| id == 0}.map do |id, count|
        Facet.new(id, id_to_name[id.to_s], count, id.to_s == search_value_for_this_facet)
      end
      
      facets.sort_by{|f| [0-f.count, f.name]}
    end
  end
  
  SUPPORTED_ORDERS = %w(Relevant Newest Oldest)
  
  attr_reader :errors, :with, :order, :start_date, :end_date
  attr_accessor :term
  
  [:agency_ids, :section_ids, :topic_ids].each do |attr|
    define_method attr do
      @with[attr]
    end
    
    define_method "#{attr}=" do |val|
      @with[attr] = val
    end
  end
  
  [:start_date, :end_date].each do |attr|
    define_method "#{attr}=" do |val|
      instance_variable_set("@#{attr}", Date.parse(val))
      @with[:publication_date] = @start_date.to_time .. @end_date.to_time
    end
  end
  
  def initialize(options = {})
    options.symbolize_keys!
    @errors = []
    @with = {}
    
    @term = options[:term]
    @num_parameters = options.except("action", "controller").size
    @per_page = 20
    @start_date = Date.parse('1994-01-01')
    @end_date = Entry.latest_publication_date
    
    @order = options[:order] || 'relevant'
    @page = options[:page] || 1
    
    self.conditions = options[:conditions] || {}
  end
  
  def conditions=(conditions)
    conditions.each_pair do |key, val|
      self.send("#{key}=", val)
    end
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
  
  def valid?
    @errors.empty?
  end
  
  def blank?
    @num_parameters == 0
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
  
  def date_distribution
    dist = Entry.facets(term,
      :with => with.except(:publication_date),
      :conditions => conditions,
      :match_mode => :extended,
      :facets => [:year_month]
    )[:year_month]
    
    (1994..Date.today.year).each do |year|
      (1..12).each do |month|
        dist[sprintf("%d/%02d",year, month)] ||= 0
      end
    end
    
    dist
  end
  
  def count_in_last_n_days(n)
    Entry.search_count(@term, 
      :with => with.merge(:publication_date => (n.days.ago .. Time.current)),
      :conditions => conditions,
      :match_mode => :extended
    )
  end
  
  def conditions
    conditions = {}
    conditions[:granule_class] = @granule_class if @granule_class.present?
    conditions
  end
  memoize :conditions
  
  def entries
    unless defined?(@entries)
      @entries = Entry.search(@term, 
        :page => @page,
        :per_page => @per_page,
        :order => order_clause,
        :with => with,
        :conditions => conditions,
        :match_mode => :extended,
        :sort_mode => :extended
      )
    
      # TODO: FIXME: Ugly hack to get total pages to be within bounds
      if @entries && @entries.total_pages > 50
        def @entries.total_pages
          50
        end
      end
    end
    @entries
  end
  
  private
  
  # def locate_places(near, within)
  #   return if near.blank?
  #   
  #   if within.blank?
  #     within = 100
  #   else
  #     within = within.to_i
  #     if within < 0 || within >= 200
  #       within = 200
  #     end
  #   end
  #   
  #   location = fetch_location(near)
  #   
  #   if location.lat
  #     places = Place.find(:all, :select => "id", :origin => location, :within => within)
  #     @place_ids = places.map{|p| p.id}
  #     
  #     if places.size > 4096
  #       @errors << 'We found too many locations near your location; please reduce the scope of your search'
  #     end
  #   else
  #     @errors << 'We could not understand your location.'
  #   end
  # end
  # 
  # def fetch_location(location)
  #   Rails.cache.fetch("location_of: '#{location}'") { Geokit::Geocoders::GoogleGeocoder.geocode(location) }
  # end
end