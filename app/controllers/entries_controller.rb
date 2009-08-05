class EntriesController < ApplicationController
  include Geokit::Geocoders
  def search
    @topics = Topic.all
    @agencies = Agency.all
    
    with = {}
    
    @search_term = params[:q]
    
    @near = params[:near]
    unless @near.blank?
      within = params[:within].to_i
      if within <= 0 || within >= 500
        within = 500
      end
      
      location = Rails.cache.fetch("location_of: '#{@near}'") { Geokit::Geocoders::GoogleGeocoder.geocode(@near) }
      
      # TODO: send error message to user on invalid location
      
      place_ids = Place.find(:all, :select => "id", :origin => location, :within => within).map &:id
      with[:place_ids] = place_ids
    end
    
    [:agency_id, :topic_ids].each do |attribute|
      unless params[attribute].blank?
        with[attribute] = params[attribute]
      end
    end
    
    if !params[:publication_date_greater_than].blank? || !params[:publication_date_less_than].blank?
      # TODO: send error message to user on invalid dates
      start_date = Chronic.parse(params[:publication_date_greater_than], :context => :past) || DateTime.parse('1994-01-01')
      end_date = Chronic.parse(params[:publication_date_less_than], :context => :past) || DateTime.parse('2100-01-01')
      with[:publication_date] = Range.new(start_date.midnight.to_f.to_i,end_date.midnight.to_f.to_i)
    end
    
    @entries = Entry.search(@search_term, 
      :page => params[:page] || 1,
      :order => "@relevance DESC, publication_date DESC",
      :with => with
    )
  end
  
  def index
    @entries = Entry.find(:all, :limit => 200, :order => "publication_date DESC")
  end
  
  def by_date
    @year = params[:year]   || Time.now.strftime("%Y")
    @month = params[:month] || Time.now.strftime("%m")
    @day   = params[:day]   || Time.now.strftime("%d")
    
    @entries = Entry.find(:all, :conditions => ['publication_date = ?', "#{@year}-#{@month}-#{@day}"], :order => 'publication_date DESC')
  end
  
  def show
    @entry = Entry.find_by_document_number(params[:document_number])
    raise "Entry doesn't exist" if @entry.nil?
  end
end