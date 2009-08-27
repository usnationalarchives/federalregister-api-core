ActionController::Routing::Routes.draw do |map|
  map.topic_groups_by_letter '/topics/:letter',
      :requirements => {:letter => /[a-z]/},
      :controller => "topic_groups",
      :action => "by_letter"
  
  map.resources :topic_groups, :as => "topics"
  
  
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

  map.entries_date_search 'entries/explore', :controller => 'entries',
                                             :action     => 'by_date'
                                       
  map.resources :entries     
  
  map.connect 'e/:document_number', :controller => 'entries',
                                    :action     => 'tiny_pulse'
  
  map.connect  'calendar/:year/:month/:day', :controller => 'calendars',
                                             :action     => 'index',
                                             :year       => /\d{4}/,
                                             :month      => /\d{1,2}/,
                                             :day        => /\d{1,2}/
  
  map.calendar_month  'calendar/:year/:month', :controller => 'calendars',
                                        :action     => 'index',
                                        :year       => /\d{4}/,
                                        :month      => /\d{1,2}/

  map.events_month 'events/:year/:month', :controller => 'calendars',
                                          :action     => 'index',
                                          :year       => /\d{4}/,
                                          :month      => /\d{1,2}/

  map.connect 'citation/:volume/:page', :controller => 'citations',
                                        :action     => 'index',
                                        :volume     => /\d{2}/

  map.maps 'maps', :controller => 'maps',
                   :action     => 'index'
                                   
  map.locations_path 'locations/:slug/:id.:format', :controller => 'locations', :action => 'show'
                                         
  map.root :controller => 'special', :action => 'home'
  
  map.about 'about', :controller => 'special', :action => 'about'
  
end
