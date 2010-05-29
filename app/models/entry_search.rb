class EntrySearch
  include Geokit::Geocoders
  extend ActiveSupport::Memoizable
  
  class Facet
    attr_reader :value, :name, :count, :on, :condition
    def initialize(options)
      @value      = options[:value]
      @name       = options[:name]
      @count      = options[:count]
      @on         = options[:on]
      @condition  = options[:condition]
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
  
  SUPPORTED_ORDERS = %w(Relevant Newest Oldest)
  
  attr_reader :errors, :with, :order, :start_date, :end_date, :type, :location, :within
  attr_accessor :term, :type
  
  [:agency_ids, :section_ids, :topic_ids].each do |attr|
    define_method attr do
      @with[attr]
    end
    
    define_method "#{attr}=" do |val|
      if val.present?
        @with[attr] = val
      end
    end
  end
  
  [:start_date, :end_date].each do |attr|
    define_method "#{attr}=" do |val|
      if val.present?
        instance_variable_set("@#{attr}", val)
        
        begin
          Date.parse(val)
        rescue
          @errors << "Could not understand #{attr.to_s.humanize.downcase}."
        else
          @with[:publication_date] = Date.parse(@start_date).to_time .. Date.parse(@end_date).to_time
        end
      end
    end
  end
  
  def within=(val)
    if val.present?
      @within = val
      if val.to_i < 1 && val.to_i > 200
        @errors < "range must be between 1 and 200 miles."
      end
    end
  end
  
  def location=(val)
    if val.present?
      @location = val
      loc = fetch_location(val)
      
      if loc.lat
        places = Place.find(:all, :select => "id", :origin => loc, :within => within)
        @with[:place_ids] = places.map{|p| p.id}
        
        if places.size > 4096
          @errors << 'We found too many locations near your location; please reduce the scope of your search'
        end
      else
        @errors << 'We could not understand your location.'
      end
    end
  end
  
  def initialize(options = {})
    options.symbolize_keys!
    @errors = []
    @with = {}
    
    # Set some defaults...
    @per_page = 20
    @start_date = '1994-01-01'
    @end_date = Entry.latest_publication_date.to_s(:db)
    @within = '25'
    @order = options[:order] || 'relevant'
    @page = options[:page] || 1
    
    self.conditions = options[:conditions] || {}
  end
  
  def conditions=(conditions)
    [:agency_ids, :section_ids, :topic_ids, :term, :type, :within, :location].each do |attr|
      if conditions[attr].present?
        self.send("#{attr}=", conditions[attr])
      end
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
    [with, conditions, term].all?(&:blank?)
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
      :conditions => conditions.except(:granule_class),
      :match_mode => :extended,
      :facets => [:granule_class]
    )[:granule_class]
    
    search_value_for_this_facet = self.type
    facets = raw_facets.to_a.reverse.reject{|id, count| id == 0}.map do |id, count|
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
      :with => with.merge(:publication_date => (n.days.ago.to_time.midnight .. Time.current.midnight)),
      :conditions => conditions,
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
  
  def conditions
    conditions = {}
    conditions[:granule_class] = @type if @type.present?
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
  
  def fetch_location(location)
    Rails.cache.fetch("location_of: '#{location}'") { Geokit::Geocoders::GoogleGeocoder.geocode(location) }
  end
end