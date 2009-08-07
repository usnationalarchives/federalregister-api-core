class AgenciesController < ApplicationController
  
  def index
    @agencies  = Agency.find(:all, :order => 'name ASC')
    @chart_max = Agency.max_entry_count
    @featured_agencies = Agency.featured
    @week = params[:week].to_i || Time.now.strftime("%W").to_i
  end
  
  def show
    @agency = Agency.find_by_slug(params[:id], 
                                  :include => :entries,
                                  :order => 'entries.publication_date DESC',
                                  :limit => 100)
    
    @agency = Agency.find_by_slug(params[:id])
    @entries = @agency.entries.all(:limit => 100, :include => :places, :order => "entries.publication_date DESC")
    @places = @entries.map{|e| e.places}.flatten.uniq.select{|p| p.usable?}
    
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
    
    
    
    respond_to do |wants|
      wants.html
      
      wants.rss do
        @feed_name = "Trifecta: #{@agency.name}"
        @feed_description = "Recent Federal Register entries from #{@agency.name}."
        @entries = @agency.entries.all(:include => [:topics, :agency], :order => "publication_date DESC", :limit => 20)
        render :template => 'entries/index.rss.builder'
      end
    end
    
  end
end