class EntriesController < ApplicationController
  caches_page :by_date, :show, :current_headlines
  
  include XmlTransformer
  helper_method :transform_xml
  
  def search
    if !params[:volume].blank? && !params[:page].blank?
      redirect_to "/citation/#{params[:volume]}/#{params[:page]}"
      return
    end
    
    @search = EntrySearch.new(params)
    
    unless @search.valid?
      flash.now[:error] = "<ul>#{@search.errors.map{|e| "<li>#{e}</li>"}}</ul>"
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
        @feed_name = 'govpulse Latest Entries'
        @entries = Entry.find(:all, :conditions => {:publication_date => Entry.latest_publication_date})
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
  end
  
  def citations
    @entry = Entry.find_by_document_number!(params[:document_number])
  end
  
  def tiny_pulse
    entry = Entry.find_by_document_number!(params[:document_number])
    redirect_to entry_path(entry)
  end
end