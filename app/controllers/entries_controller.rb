class EntriesController < ApplicationController
  caches_page :by_date, :show, :current_headlines
  
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
        @feed_name = 'Federal Register Search Results'
        render :action => 'index'
      end
    end
  end
  
  caches_action :widget, :cache_path => Proc.new { |request| request.params.delete_if{|key, val| val.blank?} }
  def widget
    params[:per_page] = 5
    params[:order] = :date
    @search = EntrySearch.new(params)
    
    render :layout => 'widget'
  end
  
  def index
    respond_to do |wants|
      wants.html do
        redirect_to entries_by_date_path(Entry.latest_publication_date)
      end
      wants.rss do
        @feed_name = 'Federal Register Latest Entries'
        @entries = Entry.find(:all, :conditions => {:publication_date => Entry.latest_publication_date})
      end
    end
  end
  
  def current_headlines
    @entries = Entry.all(
        :include => :agencies,
        :conditions => {:publication_date => Entry.latest_publication_date},
        :order => "entries.start_page"
    )
    render :layout => false
  end
  
  def date_search
    date = Chronic.parse(params[:search], :context => :past)
    raise ActiveRecord::RecordNotFound if date.nil?
    redirect_to entries_by_date_url(date)
  end
  
  def by_date
    @year  = params[:year]  || Time.now.strftime("%Y")
    @month = params[:month] || Time.now.strftime("%m")
    @day   = params[:day]   || Time.now.strftime("%d")
    @publication_date = Date.parse("#{@year}-#{@month}-#{@day}")
    
    @agencies = Agency.all(
        :include => :entries,
        :conditions => ['publication_date = ?', @publication_date],
        :order => "entries.title"
    )
    @entries_without_agency = Entry.all(
      :conditions => ['entries.agency_id IS NULL && entries.publication_date = ?', @publication_date],
      :order => "entries.title"
    )
    
    if @agencies.size == 0 && @entries_without_agency.size == 0
      raise ActiveRecord::RecordNotFound
    end
    
    @places = Place.usable.all(
      :include => :entries,
      :conditions => ['entries.publication_date = ?', @publication_date]
    )
    
    # Map
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
    
    @entries = @agencies.inject([]) {|set, agency| set += agency.entries} + @entries_without_agency
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
    redirect_to entry_path(entry), :status=>:moved_permanently
  end
end