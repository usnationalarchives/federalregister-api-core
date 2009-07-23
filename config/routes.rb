ActionController::Routing::Routes.draw do |map|
  map.resources :agencies
  
  map.entries_by_year 'entries/:year/:month', :controller => 'entries', 
                                              :year => /\d{4}/,
                                              :month => /\d{2}/
  map.resources :entries
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
