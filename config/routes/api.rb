FederalregisterApiCore::Application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      scope :defaults => { :format => 'json' } do
        match 'documentation' => 'documentation#show',
          :as => :documentation,
          :via => :get
        match 'effective-dates' => 'effective_dates#index',
          :as => :effective_dates,
          :via => :get
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
        resources :images, :only => [:show], :constraints => { :id => /.*/ }
        resources :site_notifications, :only => [:show]
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
