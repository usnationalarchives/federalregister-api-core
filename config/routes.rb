ActionController::Routing::Routes.draw do |map|
  map.resources :agencies
  
  map.entry 'entries/:year/:month/:day/:document_number/:slug', :controller => 'entries',
                                                                :action     => 'show',
                                                                :year       => /\d{4}/,
                                                                :month      => /\d{2}/,
                                                                :day        => /\d{1,2}/
                                               
  
  map.entries_by_date 'entries/:year/:month/:day', :controller => 'entries',
                                                   :action     => 'index',
                                                   :year       => /\d{4}/,
                                                   :month      => /\d{2}/,
                                                   :day        => /\d{1,2}/
                                                   
                                              
  map.entries_by_week 'entries/:year/weekly/:week', :controller => 'entries',
                                                    :action     => 'index',
                                                    :year       => /\d{4}/,
                                                    :week       => /\d{1,2}/
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
