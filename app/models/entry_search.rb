class EntrySearch < ApplicationSearch
  include Geokit::Geocoders
  
  SUPPORTED_ORDERS = %w(Relevant Newest Oldest)
  
  attr_reader :order, :type, :location, :within
  attr_accessor :type, :regulation_id_number
  
  define_filter :regulation_id_number, :label => "Regulation" do |regulation_id_number|
    RegulatoryPlan.find_by_regulation_id_number(regulation_id_number).try(:title)
  end
  
  define_filter :agency_ids,  :sphinx_type => :with
  define_filter :section_ids, :sphinx_type => :with do |section_id|
    Section.find_by_id(section_id).try(:title)
  end
  define_filter :topic_ids,   :sphinx_type => :with
  define_filter :type,        :sphinx_type => :conditions do |type|
    Entry::ENTRY_TYPES[type]
  end
  
  attr_reader :start_date
  def start_date=(val)
    if val.present?
      @start_date = val
      begin
        parsed_val = Date.parse(val)
      rescue
        @errors << "Could not understand start date."
      else
        days_ago = [30,90,365].find do |n|
          n.days.ago.to_date == parsed_val
        end
        
        if days_ago.present?
          name = "in the last #{days_ago} days"
        else
          name = "since #{parsed_val}"
        end
        
        add_filter(
          :value => parsed_val.to_time .. Entry.latest_publication_date.to_time,
          :name => name,
          :condition => :start_date,
          :label => "Date",
          :sphinx_type => :with,
          :sphinx_attribute => :publication_date
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
        add_filter(
          :value => places.map{|p| p.id},
          :name => "#{val} within #{within} miles",
          :condition => :location,
          :sphinx_attribute => :place_ids,
          :label => "Near",
          :sphinx_type => :with
        )
        
        if places.size > 4096
          @errors << 'We found too many locations near your location; please reduce the scope of your search'
        end
      else
        @errors << 'We could not understand your location.'
      end
    end
  end
  
  # def conditions
  #   conditions = {}
  #   conditions[:type] = "\"#{@type}\"" if @type.present?
  #   conditions[:regulation_id_number] = "\"#{@regulation_id_number}\"" if @regulation_id_number.present?
  #   conditions
  # end
  
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
      :conditions => conditions.except(:type),
      :match_mode => :extended,
      :facets => [:type]
    )[:type]
    
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
    sphinx_search = ThinkingSphinx::Search.new(term,
      :with => with.except(:publication_date),
      :conditions => conditions,
      :match_mode => :extended
    )
    
    client = sphinx_search.send(:client)
    client.group_function = :month
    client.group_by = "publication_date"
    client.limit = 5000
    
    query = sphinx_search.send(:query)
    dist = {}
    client.query(query, '*')[:matches].each{|m| dist[m[:attributes]["@groupby"].to_s] = m[:attributes]["@count"] }
    
    (1994..Date.today.year).each do |year|
      (1..12).each do |month|
        dist[sprintf("%d%02d",year, month)] ||= 0
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
  
  def regulatory_plan
    if @regulation_id_number
      RegulatoryPlan.find_by_regulation_id_number(@regulation_id_number)
    end
  end
  memoize :regulatory_plan
  
  private
  
  def set_defaults(options)
    @start_date = '1994-01-01'
    @within = '25'
    @order = options[:order] || 'relevant'
  end
  
  def fetch_location(location)
    Rails.cache.fetch("location_of: '#{location}'") { Geokit::Geocoders::GoogleGeocoder.geocode(location) }
  end
end