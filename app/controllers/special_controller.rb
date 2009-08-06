class SpecialController < ApplicationController
  
  def home
    # stuff here
    @entries = Entry.all(:conditions => ['publication_date = ?', Date.today])
    @featured_agencies = Agency.featured
    
    date_range = [Date.today, Date.today + 1]
    @closing_soon = ReferencedDate.find(:all, 
                                        :include => :entry, 
                                        :conditions => {:date_type => 'CommentDate', :date => date_range[0]..date_range[1]},
                                        :order => 'date ASC',
                                        :limit => 10
                                       )

    date_range = [Date.today - 7, Date.today]                                   
    @recently_opened = ReferencedDate.find(:all, 
                                           :include => :entry, 
                                           :conditions => {:date_type => 'CommentDate', 
                                                           :date => date_range[0]..date_range[1],
                                                           :entries => {:publication_date => date_range[0]..date_range[1]}
                                                          },
                                           :order => 'date ASC',
                                           :limit => 10
                                          )                                   
  end                 
end
