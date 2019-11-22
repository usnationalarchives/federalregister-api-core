FederalregisterApiCore::Application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      scope :defaults => { :format => 'json' } do
        match 'documentation' => 'documentation#show',
          :as => :documentation,
          :via => :get
        resources :effective_dates,
          :only => [:index]
        match 'documents/facets/:facet' => 'entries#facets',
          :as => :articles_facets,
          :via => :get
        match 'public-inspection-documents/facets/:facet' => 'public_inspection_documents#facets',
          :as => :public_inspection_documents_facets,
          :via => :get
        match 'public-inspection-issues/facets/:facet' => 'public_inspection_issues#facets',
          :as => :public_inspection_issues_facets,
          :via => :get
        match 'documents/search-details' => 'entries#search_details',
          :as => :articles_search_details,
          :via => :get
        match 'public-inspection-documents/search-details' => 'public_inspection_documents#search_details',
          :as => :public_inspection_documents_search_details,
          :via => :get
        resources :entries, :only => [:index, :show]
        resources :documents, :only => [:index, :show],
          :controller => :entries
        match 'agencies/suggestions' => 'agencies#suggestions',
          :as => :agency_suggestions,
          :via => :get
        resources :agencies, :only => [:index, :show]
        resources :public_inspection_documents, :only => [:index, :show]
        match 'public-inspection-documents' => 'public_inspection_documents#index',
          :via => :get
        match 'public-inspection-documents/current' => 'public_inspection_documents#current',
          :via => :get
        match 'public-inspection-documents/:id' => 'public_inspection_documents#show',
          :via => :get
        resources :site_notifications, :only => [:index, :show]
        resources :sections, :only => [:index]
        resources :suggested_searches, :only => [:index, :show]
        resources :holidays, :only => [:index]
        match 'topics/suggestions' => 'topics#suggestions',
          :as => :topic_suggestions,
          :via => :get
      end
    end
  end
end


# ActionController::Routing::Routes.draw do |map|
#   map.with_options(:path_prefix => "api/v1", :name_prefix => "api_v1_") do |api|
#     api.with_options(:path_prefix => "api/v1/doc", :controller => "api/v1/documentation", :conditions => {:method => :get}) do |doc|
#       doc.entries_attributes ':type/attributes', :action => :attributes, :quiet => true
#     end

#     api.resources :effective_dates,
#                   :as => 'effective-dates',
#                   :only => [:index],
#                   :controller => 'api/v1/effective_dates'

#     api.articles_facets 'documents/facets/:facet.:format',
#                   :controller => 'api/v1/entries',
#                   :action => 'facets',
#                   :conditions => {:method => :get}

#     api.public_inspection_documents_facets 'public-inspection-documents/facets/:facet',
#                   :controller => 'api/v1/public_inspection_documents',
#                   :action => 'facets',
#                   :conditions => {:method => :get}

#     api.public_inspection_issues_facets 'public-inspection-issues/facets/:facet',
#                   :controller => 'api/v1/public_inspection_issues',
#                   :action => 'facets',
#                   :conditions => {:method => :get}

#     api.articles_search_details 'documents/search-details',
#                   :controller => 'api/v1/entries',
#                   :action => 'search_details',
#                   :conditions => {:method => :get}

#     api.public_inspection_documents_search_details 'public-inspection-documents/search-details',
#                   :controller => 'api/v1/public_inspection_documents',
#                   :action => 'search_details',
#                   :conditions => {:method => :get}

#     api.resources :entries,
#                   :as => :documents,
#                   :only => [:index, :show],
#                   :controller => 'api/v1/entries'

#     api.agency_suggestions 'agencies/suggestions',
#                   :controller => 'api/v1/agencies',
#                   :action => 'suggestions',
#                   :conditions => {:method => :get}

#     api.resources :agencies,
#                   :only => [:index, :show],
#                   :controller => 'api/v1/agencies'

#     api.resources :public_inspection_documents,
#                   :as => 'public-inspection-documents',
#                   :only => [:index, :show],
#                   :controller => 'api/v1/public_inspection_documents',
#                   :collection => {:current => :get}

#     api.resources :site_notifications,
#                   :only => [:index, :show],
#                   :controller => 'api/v1/site_notifications'

#     api.resources :sections,
#                   :only => [:index],
#                   :controller => 'api/v1/sections',
#                   :conditions => {:method => :get}

#     api.resources :suggested_searches,
#                   :only => [:index, :show],
#                   :controller => 'api/v1/suggested_searches',
#                   :conditions => {:method => :get}

#     api.resources :holidays,
#                   :only => [:index],
#                   :controller => 'api/v1/holidays',
#                   :conditions => {:method => :get}

#     api.topic_suggestions 'topics/suggestions',
#                   :controller => 'api/v1/topics',
#                   :action => 'suggestions',
#                   :conditions => {:method => :get}
#   end
# end
