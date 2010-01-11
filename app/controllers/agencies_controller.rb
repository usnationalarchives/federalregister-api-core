class AgenciesController < ApplicationController
    
  caches_page :index, :show
  def index
    @agencies  = Agency.find(:all, :conditions => "entries_count > 0", :order => 'name ASC')
    @weekly_chart_max = @agencies.map{|a| a.entries_1_year_weekly.map(&:to_i).max}.max
    @featured_agencies = Agency.featured.find(:all, :select => "agencies.*,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{30.days.ago.to_s(:db)}') AS num_entries_month,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{90.days.ago.to_s(:db)}') AS num_entries_quarter,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{365.days.ago.to_s(:db)}') AS num_entries_year"
    )
    @week = params[:week].to_i || Time.now.strftime("%W").to_i
  end
  
  def show
    @agency = Agency.find_by_slug!(params[:id])
    @entries = @agency.entries.all(:limit => 50, :include => :places, :order => "entries.publication_date DESC")
    
    respond_to do |wants|
      wants.html do
        @places = @entries.map{|e| e.places}.flatten.uniq.select{|p| p.usable?}

        @map = Cloudkicker::Map.new( :style_id => 1714,
                                     :zoom     => 2,
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
        
        # GRANULE CLASSES
        @granule_labels = []
        @granule_values = []
        
        by_granule_class = Entry.all(
          :select => 'granule_class, count(*) AS count',
          :conditions => {:agency_id => [@agency.id] + @agency.descendant_ids},
          :group => 'granule_class',
          :order => 'count DESC'
        )
        by_granule_class.each do |summary|
          @granule_labels << summary.granule_class
          @granule_values << summary.count.to_i
        end
      end
      
      wants.rss do
        @feed_name = "govpulse: #{@agency.name}"
        @feed_description = "Recent Federal Register entries from #{@agency.name}."
        @entries = @agency.entries.all(:include => [:topics, :agency], :order => "publication_date DESC", :limit => 20)
        render :template => 'entries/index.rss.builder'
      end
    end
    
  end
end