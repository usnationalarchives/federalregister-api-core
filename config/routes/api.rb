ActionController::Routing::Routes.draw do |map|
  map.with_options(:path_prefix => "api/v1", :name_prefix => "api_v1_") do |api|
    api.resources :entries,
                  :as => :articles,
                  :only => [:index, :show],
                  :controller => 'api/v1/entries'
  end
  
  map.with_options(:path_prefix => "api/v1", :name_prefix => "api_v1_") do |api|
    api.resources :agencies,
                  :only => [:index],
                  :controller => 'api/v1/agencies'
  end
end