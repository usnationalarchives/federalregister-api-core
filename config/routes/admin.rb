FR2::Application.routes.draw do
  namespace :admin do
    match '' => 'special#home', :as => :home, :via => :get
      resources :agencies do
        member do
          get :delete
        end
    end
    resources :agency_names do
      collection do
        get :unprocessed
      end
    end
    namespace :agency_names do
      resources :issues
    end
    resources :canned_searches, :only => [:new]
    match 'canned_searches/:slug' => 'canned_searches#section', :as => :section_canned_searches, :via => :get
    resources :canned_searches do
      member do
        get :delete
      end
    end
    resources :events
    resources :dictionary_words, :only => [:create]
    resources :spelling_suggestions, :only => [:index]
    match 'index/:year.:format' => 'indexes#year', :as => :index_year, :via => :get
    match 'index/:year/publish' => 'indexes#publish', :as => :publish_index_year, :via => :post
    match 'index/:year/sgml' => 'indexes#sgml', :as => :sgml_index, :via => :get
    match 'index/:year/:agency.:format' => 'indexes#year_agency', :as => :index_year_agency, :via => :get
    match 'index/:year/:agency' => 'indexes#update_year_agency', :as => :index_year_agency, :via => :put
    match 'index/:year/:agency/unapproved-documents' => 'indexes#year_agency_unapproved_documents', :as => :index_year_agency_unapproved_documents, :via => :get
    match 'index/:year/:agency/completion' => 'indexes#mark_complete', :as => :index_year_agency_completion, :via => :put
    match 'index/:year/:agency/:type' => 'indexes#year_agency_type', :as => :index_year_agency_type, :via => :get
    resources :generated_files, :only => [:show]
    resources :topics
    resources :topic_names do
      collection do
        get :unprocessed
      end
    end
    resources :presidential_documents, :only => [:index, :create, :show]
    resources :photo_candidates, :only => [:show, :info] do
      member do
        get :info
      end
    end
    resources :sections
    resources :agency_highlights
    resources :missing_images, :only => :index
    resources :reprocessed_issues, :only => [:index, :show, :create, :update]
    match 'reprocessed_issues_update_mods/:id' => 'reprocessed_issues#update_mods', :as => :update_mods, :via => :put
    resources :issues do
        member do
          get :preview
        end
      resource :approval
      resources :entries
      resources :eventful_entries do
        resources :events
      end

      resources :sections do
        member do
          get :preview
        end
        resources :highlights
      end
    end

    match 'entries/:id/highlight' => 'issues/entries#highlight', :as => :highlight_entry, :via => :get
    resources :password_resets, :except => [:index, :show, :destroy]
    resources :users do
      resource :password
    end
    resource :user_session
    resources :site_notifications, :only => [:edit, :index, :update]
    match 'login' => 'user_sessions#new', :as => :login, :via => :get
    match 'logout' => 'user_sessions#destroy', :as => :logout, :via => :get
  end

end


# ActionController::Routing::Routes.draw do |map|
#   map.namespace :admin do |admin|
#     admin.home '', :controller => "special", :action => "home", :conditions => {:method => :get}
#     admin.resources :agencies, :member => {:delete => :get}
#     admin.resources :agency_names, :collection => {:unprocessed => :get}
#     admin.namespace 'agency_names' do |agency_names|
#       agency_names.resources :issues
#     end
#     admin.resources :canned_searches, :only => [:new]
#     admin.section_canned_searches "canned_searches/:slug", :controller => "canned_searches", :action => :section, :conditions => {:method => :get, :slug => '\w*[a-zA-Z]\w*'}
#     admin.resources :canned_searches, :member => {:delete => :get}

#     admin.resources :events

#     admin.resources :dictionary_words, :only => [:create]
#     admin.resources :spelling_suggestions, :only => [:index]

#     admin.index_year 'index/:year.:format', :controller => "indexes", :action => "year", :conditions => {:method => :get}
#     admin.publish_index_year 'index/:year/publish', :controller => "indexes", :action => "publish", :conditions => {:method => :post}
#     admin.sgml_index 'index/:year/sgml', :controller => "indexes", :action => "sgml", :conditions => {:method => :get}
#     admin.index_year_agency 'index/:year/:agency.:format', :controller => "indexes", :action => "year_agency", :conditions => {:method => :get}
#     admin.index_year_agency 'index/:year/:agency', :controller => "indexes", :action => "update_year_agency", :conditions => {:method => :put}
#     admin.index_year_agency_unapproved_documents 'index/:year/:agency/unapproved-documents', :controller => "indexes", :action => "year_agency_unapproved_documents", :conditions => {:method => :get}
#     admin.index_year_agency_completion 'index/:year/:agency/completion', :controller => "indexes", :action => "mark_complete", :conditions => {:method => :put}
#     admin.index_year_agency_type 'index/:year/:agency/:type', :controller => "indexes", :action => "year_agency_type", :conditions => {:method => :get}

#     admin.resources :generated_files, :only => [:show]

#     admin.resources :topics
#     admin.resources :topic_names, :collection => {:unprocessed => :get}

#     admin.resources :presidential_documents,:only => [:index, :create, :show]
#     admin.resources :photo_candidates, :only => [:show, :info], :member => {:info => :get}
#     admin.resources :sections
#     admin.resources :agency_highlights
#     admin.resources :missing_images, :only => :index
#     admin.resources :reprocessed_issues, :only => [:index, :show, :create, :update]
#     admin.update_mods 'reprocessed_issues_update_mods/:id', :controller => "reprocessed_issues", :action => "update_mods", :conditions => {:method => :put}

#     admin.resources :issues, :member => {:preview => :get} do |issue|
#       issue.resource :approval, :controller => "issues/approvals"
#       issue.resources :entries, :controller => "issues/entries"
#       issue.resources :eventful_entries, :controller => "issues/eventful_entries" do |entry|
#         entry.resources :events, :controller => "issues/eventful_entries/events"
#       end
#       issue.resources :sections, :controller => "issues/sections", :member => {:preview => :get} do |section|
#         section.resources :highlights, :controller => "issues/sections/highlights"
#       end
#     end
#     admin.highlight_entry 'entries/:id/highlight', :controller => "issues/entries", :action => "highlight", :conditions => {:method => :get}

#     admin.resources :password_resets, :except => [:index, :show, :destroy]
#     admin.resources :users do |user|
#       user.resource :password, :controller => "users/passwords"
#     end

#     admin.resource :user_session
#     admin.resources :site_notifications, :only => [:edit, :index, :update]
#     admin.login  'login',  :controller => "user_sessions", :action => "new", :conditions => {:method => :get}
#     admin.logout 'logout', :controller => "user_sessions", :action => "destroy", :conditions => {:method => :get}
#   end
# end
