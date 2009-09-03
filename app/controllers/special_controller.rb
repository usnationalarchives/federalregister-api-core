class SpecialController < ApplicationController
  caches_page :home
  
  def home
    # stuff here
    @last_date = Entry.latest_publication_date
    @featured_agencies = Agency.featured.all
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
    
    #HELP-RUBY this isn't very helpful unless the comment date is < current date
    @recent_proposed_rules = Entry.all( :conditions => {:granule_class => 'PRORULE'},
                                        :order => 'publication_date DESC',
                                        :limit => 10
                                        )
  end                 
end
