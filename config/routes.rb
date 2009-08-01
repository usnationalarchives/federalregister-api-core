ActionController::Routing::Routes.draw do |map|
  map.resources :topics
  
  map.connect 'agencies/:year/weekly/:week', :controller => 'agencies',
                                             :action     => 'index',
                                             :year       => /\d{4}/,
                                             :week       => /\d{1,2}/
  
  map.resources :agencies
  map.entries 'entries', :controller => 'entries', :action => 'index'
  
  map.entries_search 'entries/search', :controller => 'entries', :action => 'search'
  map.entry 'entries/:year/:month/:day/:document_number/:slug', :controller => 'entries',
                                                                :action     => 'show',
                                                                :year       => /\d{4}/,
                                                                :month      => /\d{1,2}/,
                                                                :day        => /\d{1,2}/
                                               
  
  map.entries_by_date 'entries/:year/:month/:day', :controller => 'entries',
                                                   :action     => 'by_date',
                                                   :year       => /\d{4}/,
                                                   :month      => /\d{1,2}/,
                                                   :day        => /\d{1,2}/
                                                   
                                              
  map.entries_by_week 'entries/:year/weekly/:week', :controller => 'entries',
                                                    :action     => 'index',
                                                    :year       => /\d{4}/,
                                                    :week       => /\d{1,2}/
  map.resources :entries                                                  
  
  map.connect  'calendar/:year/:month/:day', :controller => 'calendars',
                                             :action     => 'index',
                                             :year       => /\d{4}/,
                                             :month      => /\d{1,2}/,
                                             :day        => /\d{1,2}/
  
  map.connect  'calendar/:year/:month', :controller => 'calendars',
                                        :action     => 'index',
                                        :year       => /\d{4}/,
                                        :month      => /\d{1,2}/
                                        
  map.root :controller => 'special', :action => 'home'
end
