ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.home '', :controller => "special", :action => "home", :conditions => {:method => :get}
    admin.resources :agencies, :member => {:delete => :get}
    admin.resources :agency_names, :collection => {:unprocessed => :get}
    admin.namespace 'agency_names' do |agency_names|
      agency_names.resources :issues
    end
    admin.resources :canned_searches, :only => [:new]
    admin.section_canned_searches "canned_searches/:slug", :controller => "canned_searches", :action => :section, :conditions => {:method => :get, :slug => '\w*[a-zA-Z]\w*'}
    admin.resources :canned_searches, :member => {:delete => :get}
       
    admin.resources :events

    admin.resources :dictionary_words, :only => [:create]
    
    admin.index_year 'index/:year.:format', :controller => "indexes", :action => "year", :conditions => {:method => :get}
    admin.publish_index_year 'index/:year/publish', :controller => "indexes", :action => "publish", :conditions => {:method => :post}
    admin.index_year_agency 'index/:year/:agency.:format', :controller => "indexes", :action => "year_agency", :conditions => {:method => :get}
    admin.index_year_agency 'index/:year/:agency', :controller => "indexes", :action => "update_year_agency", :conditions => {:method => :put}
    admin.index_year_agency_completion 'index/:year/:agency/completion', :controller => "indexes", :action => "mark_complete", :conditions => {:method => :put}

    admin.resources :generated_files, :only => [:show]

    admin.resources :topics
    admin.resources :topic_names, :collection => {:unprocessed => :get}
    
    admin.resources :photo_candidates, :only => :show
    admin.resources :sections
    admin.resources :agency_highlights
    
    admin.resources :issues, :member => {:preview => :get} do |issue|
      issue.resource :approval, :controller => "issues/approvals"
      issue.resources :entries, :controller => "issues/entries"
      issue.resources :eventful_entries, :controller => "issues/eventful_entries" do |entry|
        entry.resources :events, :controller => "issues/eventful_entries/events"
      end
      issue.resources :sections, :controller => "issues/sections", :member => {:preview => :get} do |section|
        section.resources :highlights, :controller => "issues/sections/highlights"
      end
    end
    admin.highlight_entry 'entries/:id/highlight', :controller => "issues/entries", :action => "highlight", :conditions => {:method => :get}
    
    admin.resources :password_resets, :except => [:index, :show, :destroy]
    admin.resources :users do |user|
      user.resource :password, :controller => "users/passwords"
    end
    
    admin.resource :user_session
    admin.login  'login',  :controller => "user_sessions", :action => "new", :conditions => {:method => :get}
    admin.logout 'logout', :controller => "user_sessions", :action => "destroy", :conditions => {:method => :get}
  end
end
