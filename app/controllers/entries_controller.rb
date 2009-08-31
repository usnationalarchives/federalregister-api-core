class EntriesController < ApplicationController
  caches_page :index, :by_date, :show, :current_headlines
  
  include Geokit::Geocoders
  
  def search
    with = {}
    
    @search_term = params[:q]
    
    errors = []
    
    @near = params[:near]
    if params[:place_id]
      @place = Place.find(params[:place_id])
      with[:place_ids] = @place.id
    else
      unless @near.blank?
        @within = params[:within]
        if params[:within].blank?
          @within = 100
        else
          @within = params[:within].to_i
          if @within < 0 || @within >= 200
            @within = 200
          end
        end
        
        location = Rails.cache.fetch("location_of: '#{@near}'") { Geokit::Geocoders::GoogleGeocoder.geocode(@near) }
        
        if location.lat
          places = Place.find(:all, :select => "id", :origin => location, :within => @within)
          with[:place_ids] = places.map{|p| p.id}
          
          if places.size > 4096
            errors << 'We found too many locations near your location; please reduce the scope of your search'
          end
        else
          errors << 'We could not understand your location.'
        end
      end
    end
    
    unless params[:agency_id].blank?
      with[:agency_id] = params[:agency_id]
    end
    
    unless params[:topic_id].blank?
      @topic = Topic.find(params[:topic_id])
      with[:topic_ids] = params[:topic_id]
    end
    
    if !params[:publication_date_greater_than].blank? || !params[:publication_date_less_than].blank?
      @start_date = Chronic.parse(params[:publication_date_greater_than], :context => :past)
      
      if ! params[:publication_date_greater_than].blank? && @start_date.nil?
        errors << 'We could not understand your start date.'
      end
      
      @end_date = Chronic.parse(params[:publication_date_less_than], :context => :past)
      if ! params[:publication_date_less_than].blank? && @end_date.nil?
        errors << 'We could not understand your end date.'
      end
      
      @start_date ||= DateTime.parse('1994-01-01')
      @end_date ||= Entry.latest_publication_date
      
      with[:publication_date] = Range.new(@start_date.midnight.to_f.to_i,@end_date.midnight.to_f.to_i)
    end
    
    unless errors.blank?
      flash[:error] = "<ul>#{errors.map{|e| "<li>#{e}</li>"}}</ul>"
    end
    
    order = "publication_date DESC, @relevance DESC"
    if params[:order] == 'relevance'
      order = "@relevance DESC, publication_date DESC"
    end
    
    if errors.size == 0 && (!@search_term.blank?) || with.values.any?{|v| ! v.blank?}
      @entries = Entry.search(@search_term, 
        :page => params[:page] || 1,
        :order => order,
        :with => with
      )
    end
    
    # TODO: FIXME: Ugly hack to get total pages to be within bounds
    if @entries && @entries.total_pages > 50
      def @entries.total_pages
        50
      end
    end
    
    respond_to do |wants|
      wants.html do
        @agencies = Agency.all(:conditions => "entries_count > 0", :order => :name)
        
        render :action => 'search'
      end
      
      wants.rss do 
        @entries ||= []
        @feed_name = 'govpulse Search Results'
        render :action => 'index'
      end
    end
  end
  
  def index
    respond_to do |wants|
      wants.html do
        redirect_to entries_by_date_path(Entry.latest_publication_date)
      end
      wants.rss do
        @entries = Entry.find(:all, :limit => 200, :order => "publication_date DESC")
      end
    end
  end
  
  def current_headlines
    @entries = Entry.all(
        :include => :agency,
        :conditions => {:publication_date => Entry.latest_publication_date},
        :order => "entries.start_page"
    )
    render :layout => false
  end
  
  def by_date
    if params[:search]
      time = Chronic.parse(params[:search], :context => :past)
      raise ActiveRecord::RecordNotFound unless !time.nil?
      @year  = time.year
      @month = time.month || 1
      @day   = time.day || 1
    else
      @year  = params[:year]  || Time.now.strftime("%Y")
      @month = params[:month] || Time.now.strftime("%m")
      @day   = params[:day]   || Time.now.strftime("%d")
    end
    
    @show_calendars = params[:show_calendars]
      
    
    @publication_date = Date.parse("#{@year}-#{@month}-#{@day}")
    
    @prev_date = Entry.find(:first,
        :select => 'publication_date',
        :conditions => ["publication_date < ?", @publication_date],
        :order => 'publication_date DESC'
    ).try(:publication_date)
    
    @next_date = Entry.find(:first,
        :select => 'publication_date',
        :conditions => ["publication_date > ?", @publication_date],
        :order => 'publication_date'
    ).try(:publication_date)
    
    @agencies = Agency.all(
        :include => :entries,
        :conditions => ['publication_date = ?', @publication_date],
        :order => "entries.title"
    )
    @entries_without_agency = Entry.all(
      :conditions => ['entries.agency_id IS NULL && entries.publication_date = ?', @publication_date],
      :order => "entries.title"
    )
    @entry_count = Entry.count(:conditions => ['entries.publication_date = ?', @publication_date])
    
    if @entry_count == 0
      raise ActiveRecord::RecordNotFound
    end
    
    @places = Place.usable.all(
      :include => :entries,
      :conditions => ['entries.publication_date = ?', @publication_date]
    )
    
    @labels = []
    @values = []
    @agencies.sort_by{|a| a.entries.size}.reverse[0,10].each do |agency|
      @labels << "#{agency.name}"
      @values << agency.entries.size
    end
    
    if @values.sum < @entry_count
      count = (@entry_count - @values.sum)
      @labels << "Other"
      @values << count
    end
    
    if !@places.blank?
      @map = Cloudkicker::Map.new( :style_id => 1714,
                                   :zoom     => 1,
                                   :lat      => @places.map(&:latitude).average,
                                   :long     => @places.map(&:longitude).average
                                 )
      @places.each do |place|
        Cloudkicker::Marker.new( :map   => @map, 
                                 :lat   => place.latitude,
                                 :long  => place.longitude, 
                                 :title => 'Click to view location info',
                                 :info  => render_to_string(:partial => 'maps/place_with_entries_marker_tooltip', :locals => {:place => place} ),
                                 :info_max_width => 200
                               )
      end
    end
    
    @granule_labels = []
    @granule_values = []
    @entries = []
    @agencies.each do |agency|
      @entries << agency.entries
    end
    @entries << @entries_without_agency
    @entries = @entries.flatten
    @entries.group_by(&:granule_class).each do |granule_class, entries|
      @granule_labels << granule_class
      @granule_values << entries.size
    end
  end
  
  def show
    @entry = Entry.find_by_document_number!(params[:document_number])
    
    if !@entry.places.usable.blank?
      
      @dist = 20
      @places = @entry.places.usable
    
      @map = Cloudkicker::Map.new( :style_id => 1714,
                                   :zoom     => 1,
                                   :lat      => @places.map(&:latitude).average,
                                   :long     => @places.map(&:longitude).average
                                 )
      @places.each do |place|
        Cloudkicker::Marker.new( :map   => @map, 
                                 :lat   => place.latitude,
                                 :long  => place.longitude, 
                                 :title => 'Click to view location info',
                                 :info  => render_to_string(:partial => 'maps/place_marker_tooltip', :locals => {:place => place} ),
                                 :info_max_width => 200
                               )
      end
    end
    members_of_congress = Sunlight::Legislator.all_in_zipcode(94110)
    @senators = members_of_congress.reject{|l| l.title != 'Sen'}
    @reps     = members_of_congress.reject{|l| l.title != 'Rep'}
  end
  
  def tiny_pulse
    entry = Entry.find_by_document_number!(params[:document_number])
    redirect_to entry_path(entry)
  end
end