class SpecialController < ApplicationController
  caches_page :home
  
  def home
    # stuff here
    @last_date = Entry.latest_publication_date
    @featured_agencies = Agency.featured.find(:all, :select => "agencies.*,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{30.days.ago.to_s(:db)}') AS num_entries_month,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{90.days.ago.to_s(:db)}') AS num_entries_quarter,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{365.days.ago.to_s(:db)}') AS num_entries_year"
    )
    
    @location = current_location
    @places = Place.find_near(@location)
    
    @closing_soon = ReferencedDate.find(:all, 
                                        :include => {:entry => :agency},
                                        :joins => {:entry => :place_determinations},
                                        :conditions => {
                                          :date_type => 'CommentDate',
                                          :place_determinations => { :place_id => @places },
                                          :date => (Date.today .. Date.today + 360)
                                        },
                                        :order => 'date ASC',
                                        :limit => 10
                                       )

     @recent_entries = Entry.find(:all,
                                   :include => :agency,
                                   :joins => :place_determinations,
                                   :conditions => {
                                     :place_determinations => { :place_id => @places },
                                     :publication_date => (Date.today - 90 .. Date.today)
                                   },
                                   :order => 'entries.publication_date DESC',
                                   :limit => 20
                                  )
  end
end
