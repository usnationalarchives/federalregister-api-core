ActionController::Routing::Routes.draw do |map|
  map.with_options(:path_prefix => "api/v1", :name_prefix => "api_v1_") do |api|
    api.with_options(:path_prefix => "api/v1/doc", :controller => "api/v1/documentation", :conditions => {:method => :get}) do |doc|
      doc.entries_attributes ':type/attributes', :action => :attributes, :quiet => true
      doc.entries_attributes 'documentation', :action => :show, :quiet => true
    end

    api.resources :effective_dates,
                  :as => 'effective-dates',
                  :only => [:index],
                  :controller => 'api/v1/effective_dates'

    api.articles_facets 'documents/facets/:facet.:format',
                  :controller => 'api/v1/entries',
                  :action => 'facets',
                  :conditions => {:method => :get}

    api.public_inspection_documents_facets 'public-inspection-documents/facets/:facet',
                  :controller => 'api/v1/public_inspection_documents',
                  :action => 'facets',
                  :conditions => {:method => :get}

    api.public_inspection_issues_facets 'public-inspection-issues/facets/:facet',
                  :controller => 'api/v1/public_inspection_issues',
                  :action => 'facets',
                  :conditions => {:method => :get}

    api.articles_search_details 'documents/search-details',
                  :controller => 'api/v1/entries',
                  :action => 'search_details',
                  :conditions => {:method => :get}

    api.public_inspection_documents_search_details 'public-inspection-documents/search-details',
                  :controller => 'api/v1/public_inspection_documents',
                  :action => 'search_details',
                  :conditions => {:method => :get}

    api.resources :entries,
                  :as => :documents,
                  :only => [:index, :show],
                  :controller => 'api/v1/entries'

    api.agency_suggestions 'agencies/suggestions',
                  :controller => 'api/v1/agencies',
                  :action => 'suggestions',
                  :conditions => {:method => :get}

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

    api.resources :holidays,
                  :only => [:index],
                  :controller => 'api/v1/holidays',
                  :conditions => {:method => :get}

    api.topic_suggestions 'topics/suggestions',
                  :controller => 'api/v1/topics',
                  :action => 'suggestions',
                  :conditions => {:method => :get}
  end
end
