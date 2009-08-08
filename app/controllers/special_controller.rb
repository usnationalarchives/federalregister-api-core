class SpecialController < ApplicationController
  
  def home
    # stuff here
    @last_date = Entry.find(:first, :select => "publication_date", :order => "publication_date DESC").publication_date
    @entries = Entry.all(:conditions => ['publication_date = ?', @last_date])
    @featured_agencies = Agency.featured.find(:all, :select => "agencies.*,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{30.days.ago.to_s(:db)}') AS num_entries_month,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{90.days.ago.to_s(:db)}') AS num_entries_quarter,
        (SELECT count(*) FROM entries WHERE agency_id = agencies.id AND publication_date > '#{365.days.ago.to_s(:db)}') AS num_entries_year"
    )
    
    date_range = [Date.today, Date.today + 7]
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
