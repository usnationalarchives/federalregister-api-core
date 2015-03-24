ActionController::Routing::Routes.draw do |map|
  map.with_options(:path_prefix => "api/v1", :name_prefix => "api_v1_") do |api|
    api.with_options(:path_prefix => "api/v1/doc", :controller => "api/v1/documentation", :conditions => {:method => :get}) do |doc|
      doc.entries_attributes ':type/attributes', :action => :attributes, :quiet => true
    end

    api.articles_facets 'articles/facets/:facet',
                  :controller => 'api/v1/entries',
                  :action => 'facets',
                  :conditions => {:method => :get}

    api.articles_search_details 'articles/search-details',
                  :controller => 'api/v1/entries',
                  :action => 'search_details',
                  :conditions => {:method => :get}

    api.resources :entries,
                  :as => :articles,
                  :only => [:index, :show],
                  :controller => 'api/v1/entries'
  
    api.resources :agencies,
                  :only => [:index, :show],
                  :controller => 'api/v1/agencies'

    api.resources :public_inspection_documents,
                  :as => 'public-inspection-documents',
                  :only => [:index, :show],
                  :controller => 'api/v1/public_inspection_documents',
                  :collection => {:current => :get}

    api.resources :site_notifications,
                  :only => [:index, :show],
                  :controller => 'api/v1/site_notifications'

    api.resources :sections,
                  :only => [:index],
                  :controller => 'api/v1/sections',
                  :conditions => {:method => :get}

    api.resources :suggested_searches,
                  :only => [:index, :show],
                  :controller => 'api/v1/suggested_searches',
                  :conditions => {:method => :get}

  end
end
