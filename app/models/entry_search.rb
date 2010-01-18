class EntrySearch
  include Geokit::Geocoders
  extend ActiveSupport::Memoizable
  
  attr_reader :errors, :topic, :agency, :search_term, :start_date, :end_date
  
  def initialize(options)
    options ||= {}
    @errors = []
    @search_term = options[:q] unless options[:q].blank?
    
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
  
  def facets
    raw_facets = Entry.facets(@search_term,
      :with => with,
      :match_mode => :extended
    )
    
    facets = {}
    if with[:agency_id].blank?
      agency_facets = raw_facets[:agency_id].to_a.sort_by{|a,b| b}.reverse.reject{|id, count| id == 0}.map do |id, count|
        [Agency.find(id), count]
      end
      facets[:agencies] = agency_facets if agency_facets.size > 1
    end
    
    if with[:topic_ids].blank?
      topic_facets = raw_facets[:topic_ids].to_a.sort_by{|a,b| b}.reverse.reject{|id, count| id == 0}.map do |id, count|
        [Topic.find(id), count]
      end
      facets[:topics] = topic_facets if topic_facets.size > 1
    end
    
    if with[:part_name].blank?
      part_name_facets = facets[:part_name]
      raw_facets[:part_name] = part_name_facets if part_name_facets && part_name_facets.size > 1
    end
    
    facets
  end
  memoize :facets
  
  def with
    with = {}
    
    with[:place_ids] = @place_ids if @place_ids.present?
    with[:topic_ids] = @topic.id if @topic 
    with[:agency_id] = @agency.id if @agency
    with[:publication_date] = Range.new(@start_date.midnight.to_f.to_i, @end_date.midnight.to_f.to_i)
    
    with
  end
  memoize :with
  
  def entries
    
    @entries = Entry.search(@search_term, 
      :page => @page,
      :order => @order,
      :with => with,
      :match_mode => :extended
    )
    
    # TODO: FIXME: Ugly hack to get total pages to be within bounds
    if @entries && @entries.total_pages > 50
      def @entries.total_pages
        50
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