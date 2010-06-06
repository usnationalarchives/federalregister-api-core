class EntriesController < ApplicationController
  def search
    if !params[:volume].blank? && !params[:page].blank?
      redirect_to "/citation/#{params[:volume]}/#{params[:page]}"
      return
    end
    
    @search = EntrySearch.new(params)
    
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
  
  def search_facet
    @search = EntrySearch.new(params)
    facets = @search.send(params[:facet] + "_facets")
    render :partial => "search/facet", :collection => facets, :layout => nil
  end
  
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
      :include => [:entries],
      :conditions => ['publication_date = ?', @publication_date],
      :order => "agencies.name, entries.title"
    )
    Agency.preload_associations(@agencies, :children)
    Entry.preload_associations(@agencies.map(&:entries).flatten, :agencies)
    
    @entries_without_agency = Entry.all(
      :include => :agencies,
      :conditions => ['agencies.id IS NULL && entries.publication_date = ?', @publication_date],
      :order => "entries.title"
    )
    
    if @agencies.blank? && @entries_without_agency.blank?
      raise ActiveRecord::RecordNotFound
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
  
  def tiny_url
    entry = Entry.find_by_document_number!(params[:document_number])
    redirect_to entry_path(entry), :status=>:moved_permanently
  end
end