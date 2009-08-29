class AgenciesController < ApplicationController
  caches_page :index, :show
  def index
    @agencies  = Agency.find(:all, :conditions => "entries_count > 0", :order => 'name ASC')
    @weekly_chart_max = @agencies.map{|a| ActiveSupport::JSON::decode(a.entries_1_year_weekly).map(&:to_i).max}.max
    @featured_agencies = Agency.featured.find(:all, :select => "agencies.*,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{30.days.ago.to_s(:db)}') AS num_entries_month,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{90.days.ago.to_s(:db)}') AS num_entries_quarter,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{365.days.ago.to_s(:db)}') AS num_entries_year"
    )
    @week = params[:week].to_i || Time.now.strftime("%W").to_i
  end
  
  def show
    @agency = Agency.find_by_slug!(params[:id])
    @entries = @agency.entries.all(:limit => 100, :include => :places, :order => "entries.publication_date DESC")
    
    respond_to do |wants|
      wants.html do
        @places = @entries.map{|e| e.places}.flatten.uniq.select{|p| p.usable?}

        @map = Cloudkicker::Map.new( :style_id => 1714,
                                     :bounds   => true,
                                     :points   => @places
                                   )
        @places.each do |place|
          Cloudkicker::Marker.new( :map   => @map, 
                                   :lat   => place.lat,
                                   :long  => place.lng, 
                                   :title => 'Click to view location info',
                                   :info  => render_to_string(:partial => 'maps/place_marker_tooltip', :locals => {:place => place} ),
                                   :info_max_width => 200
                                 )
        end

        @granule_labels = []
        @granule_values = []
        @entries.group_by(&:granule_class).each do |granule_class, entries|
          @granule_labels << granule_class
          @granule_values << entries.size
        end

        # TODO: fix the craziness!
        @popular_topic_groups = Topic.find(:all, :select => "topics.group_name AS group_name, topics.name, COUNT(*) AS entries_count",
            :conditions => ["entries.agency_id = ?", @agency.id],
            :joins => :entries,
            :group => "topics.group_name",
            :order => "LENGTH(topics.name)")
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