class SpecialController < ApplicationController
  caches_page :home
  
  def home
    @last_date = Entry.latest_publication_date
    @featured_agencies = Agency.featured.all
    @location = current_location
    
    next_week = Date.today .. Date.today + 7.days
    this_week = Date.today - 7.days .. Date.today
    @closing_soon = Agency.find(:all,
                                :include => {:entries => :referenced_dates},
                                :conditions => {:referenced_dates => {:date_type => 'CommentDate', :date => next_week}},
                                :order => 'referenced_dates.date ASC')
    @recently_opened = Agency.find(:all,
                                :include => {:entries => :referenced_dates},
                                :conditions => {:referenced_dates => {:date_type => 'CommentDate', :date => this_week}},
                                :order => 'referenced_dates.date ASC')
    @effective_this_week = Agency.find(:all,
                                :include => {:entries => :referenced_dates},
                                :conditions => {:referenced_dates => {:date_type => 'EffectiveDate', :date => this_week}},
                                :order => 'referenced_dates.date ASC')
    @recent_proposed_rules_by_agency = Agency.find(:all,
                                :include => :entries,
                                :conditions => {:entries => {:publication_date => this_week, :granule_class => 'PRORULE' }},
                                :order => 'entries.publication_date DESC')
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
