class EntrySearch
  include Geokit::Geocoders
  extend ActiveSupport::Memoizable
  
  attr_reader :errors, :topic, :agency, :search_term, :start_date, :end_date, :granule_class, :per_page
  
  def initialize(options)
    options ||= {}
    @errors = []
    @search_term = options[:q] unless options[:q].blank?
    @num_parameters = options.except("action", "controller").size
    @per_page = options[:per_page] || 20
    
    if options[:place_id].present?
      @place = Place.find(options[:place_id])
      @place_ids = [ @place.id ]
    else
      locate_places(options[:near], options[:within])
    end
    
    if options[:topic_id].present?
      @topic = Topic.find(options[:topic_id])
    end
    
    if options[:agency_id].present?
      @agency = Agency.find(options[:agency_id])
    end
    
    if options[:granule_class].present?
      @granule_class = options[:granule_class]
    end
    
    if options[:publication_date_greater_than].present?
      @start_date = Chronic.parse(options[:publication_date_greater_than], :context => :past)
      errors << 'We could not understand your start date.' if @start_date.nil?
    end
    @start_date ||= DateTime.parse('1994-01-01')
    
    if options[:publication_date_less_than].present?
      @end_date = Chronic.parse(options[:publication_date_less_than], :context => :past)
      errors << 'We could not understand your end date.' if @end_date.nil?
    end
    @end_date ||= Entry.latest_publication_date
    
    
    @order = if options[:order] == 'relevance'
              "@relevance DESC, publication_date DESC"
            else
              "publication_date DESC, @relevance DESC"
            end
    @page = options[:page] || 1
  end
  
  def valid?
    @errors.empty?
  end
  
  def blank?
    @num_parameters == 0
  end
  
  def facets
    raw_facets = Entry.facets(@search_term,
      :with => with,
      :conditions => conditions,
      :match_mode => :extended,
      :facets => [:granule_class, :agency_id]
    )
    facets = {}
    if with[:agency_id].blank?
      agency_facets = raw_facets[:agency_id].to_a.sort_by{|a,b| b}.reverse.reject{|id, count| id == 0}.slice(0,25).map do |id, count|
        [Agency.find(id), count]
      end
      facets[:agencies] = agency_facets if agency_facets.size > 1
    end
    
    if with[:topic_ids].blank?
      topic_facets = raw_facets[:topic_ids].to_a.sort_by{|a,b| b}.reverse.reject{|id, count| id == 0}.slice(0,25).map do |id, count|
        [Topic.find(id), count]
      end
      facets[:topics] = topic_facets if topic_facets.size > 1
    end
    
    if conditions[:granule_class].blank?
      granule_class_facets = raw_facets[:granule_class]
      facets[:granule_classes] = granule_class_facets# if granule_class_facets && granule_class_facets.size > 1
    end
    
    facets
  end
  memoize :facets
  
  def conditions
    conditions = {}
    conditions[:granule_class] = @granule_class if @granule_class.present?
    conditions
  end
  memoize :conditions
  def with
    with = {}
    
    with[:place_ids] = @place_ids if @place_ids.present?
    with[:topic_ids] = @topic.id if @topic 
    with[:agency_ids] = @agency.id if @agency
    with[:publication_date] = Range.new(@start_date.midnight.to_f.to_i, @end_date.midnight.to_f.to_i)
    
    with
  end
  memoize :with
  
  def entries
    unless defined?(@entries)
      @entries = Entry.search(@search_term, 
        :page => @page,
        :per_page => @per_page,
        :order => @order,
        :with => with,
        :conditions => conditions,
        :match_mode => :extended
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
  
  def locate_places(near, within)
    return if near.blank?
    
    if within.blank?
      within = 100
    else
      within = within.to_i
      if within < 0 || within >= 200
        within = 200
      end
    end
    
    location = fetch_location(near)
    
    if location.lat
      places = Place.find(:all, :select => "id", :origin => location, :within => within)
      @place_ids = places.map{|p| p.id}
      
      if places.size > 4096
        @errors << 'We found too many locations near your location; please reduce the scope of your search'
      end
    else
      @errors << 'We could not understand your location.'
    end
  end
  
  def fetch_location(location)
    Rails.cache.fetch("location_of: '#{location}'") { Geokit::Geocoders::GoogleGeocoder.geocode(location) }
  end
end