class SpecialController < ApplicationController
  caches_page :home
  
  def home
    @last_date = Entry.latest_publication_date
    @featured_agencies = Agency.featured.all
    @location = current_location
    
    next_week = Date.today .. Date.today + 7.days
    this_week = Date.today - 7.days .. Date.today
    @closing_soon = Entry.find(:all,
                                :include => [:agency, :comments_close_date],
                                :conditions => {:referenced_dates => {:date => next_week}},
                                :order => 'referenced_dates.date ASC').group_by(&:agency).reject{|a,e| a.nil?}
    @recently_opened = Entry.find(:all,
                                :include => [:agency, :comments_close_date],
                                :conditions => {:referenced_dates => {:date => this_week}},
                                :order => 'referenced_dates.date ASC').group_by(&:agency).reject{|a,e| a.nil?}
    @effective_this_week = Entry.find(:all,
                                :include => [:agency, :effective_date],
                                :conditions => {:referenced_dates => {:date => this_week}},
                                :order => 'referenced_dates.date ASC').group_by(&:agency).reject{|a,e| a.nil?}
    @recent_proposed_rules_by_agency = Entry.find(:all,
                                :include => :agency,
                                :conditions => {:entries => {:publication_date => this_week, :granule_class => 'PRORULE' }},
                                :order => 'entries.publication_date DESC').group_by(&:agency).reject{|a,e| a.nil?}
    @dist = 20
    @location = current_location
    @lat  = @location.lat
    @long = @location.lng
    @places = Place.usable.find_near([@lat,@long], :within => @dist, :limit => 20)
    
    @map = Cloudkicker::Map.new( :style_id => 1714,
                                 :zoom     => 8,
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
