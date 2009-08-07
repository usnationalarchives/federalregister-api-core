class EntriesController < ApplicationController
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
        within = params[:within].to_i
        if within <= 0 || within >= 500
          within = 500
        end
      
        location = Rails.cache.fetch("location_of: '#{@near}'") { Geokit::Geocoders::GoogleGeocoder.geocode(@near) }
      
        if location.lat
          place_ids = Place.find(:all, :select => "id", :origin => location, :within => within).map &:id
          with[:place_ids] = place_ids
        else
          errors << 'We could not understand your location.'
        end
      end
    end
    
    if params[:agency_id]
      with[:agency_id] = params[:agency_id]
    end
    
    if params[:topic_id]
      @topic = Topic.find(params[:topic_id])
      with[:agency_ids] = params[:topic_id]
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
      @end_date ||= Entry.last.publication_date.to_datetime
      
      with[:publication_date] = Range.new(@start_date.midnight.to_f.to_i,@end_date.midnight.to_f.to_i)
    end
    
    unless errors.blank?
      flash[:error] = "<ul>#{errors.map{|e| "<li>#{e}</li>"}}</ul>"
    end
    
    order = "publication_date DESC, @relevance DESC"
    if params[:order] == 'relevance'
      order = "@relevance DESC, publication_date DESC"
    end
    
    # raise with.inspect
    
    @entries = Entry.search(@search_term, 
      :page => params[:page] || 1,
      :order => order,
      :with => with
    )
    
    respond_to do |wants|
      wants.html do
        @agencies = Agency.all(:order => :name)
        
        render :action => 'search'
      end
      
      wants.rss do 
        @feed_name = 'GovPulse Search Results'
        render :action => 'index'
      end
    end
  end
  
  def index
    @entries = Entry.find(:all, :limit => 200, :order => "publication_date DESC")
  end
  
  def by_date
    @year  = params[:year]  || Time.now.strftime("%Y")
    @month = params[:month] || Time.now.strftime("%m")
    @day   = params[:day]   || Time.now.strftime("%d")
    
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
      @map = Cloudkicker::Map.new( :style_id          => 1714,
                                   :bounds            => true,
                                   :points            => @places
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
  end
  
  def show
    @entry = Entry.find_by_document_number!(params[:document_number])
    
    if !@entry.places.usable.blank?
      
      @dist = 20
      @places = @entry.places.usable
    
      @map = Cloudkicker::Map.new( :style_id => 1714,
                                   :bounds   => true,
                                   :points   => @places
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
  end
end