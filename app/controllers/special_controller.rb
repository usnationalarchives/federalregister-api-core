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
    
    date_range = [Date.today, Date.today + 7]
    @closing_soon = ReferencedDate.find(:all, 
                                        :include => {:entry => :agency}, 
                                        :conditions => {:date_type => 'CommentDate', :date => date_range[0]..date_range[1]},
                                        :order => 'date ASC',
                                        :limit => 10
                                       )

    date_range = [Date.today - 7, Date.today]
    @recently_opened = ReferencedDate.find(:all, 
                                           :include => {:entry => :agency}, 
                                           :conditions => {:date_type => 'CommentDate', 
                                                           :date => date_range[0]..date_range[1],
                                                           :entries => {:publication_date => date_range[0]..date_range[1]}
                                                          },
                                           :order => 'date ASC',
                                           :limit => 10
                                          )
    #@location = remote_location
  end                 
end
