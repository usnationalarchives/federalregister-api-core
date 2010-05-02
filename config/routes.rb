ActionController::Routing::Routes.draw do |map|
  # ADMIN
  map.namespace :admin do |admin|
    admin.home '', :controller => "special", :action => "home"
    admin.resources :agencies
    admin.resources :agency_names, :collection => {:unprocessed => :get}
    
    admin.resources :sections
    
    admin.resources :issues do |issue|
      issue.resources :sections, :controller => "issues/sections" do |section|
        section.resources :highlights, :controller => "issues/sections/highlights"
      end
    end
    
    admin.resources :password_resets
    admin.resources :users do |user|
      user.resource :password, :controller => "users/passwords"
    end
    
    admin.resource :user_session
    admin.login  'login',  :controller => "user_sessions", :action => "new"
    admin.logout 'logout', :controller => "user_sessions", :action => "destroy"
  end
  
  # SPECIAL PAGES
  map.root :controller => 'special', :action => 'home'
  map.widget_instructions 'widget_instructions', :controller => 'special', :action => 'widget_instructions'

  # ENTRIES
  map.entries 'entries.:format', :controller => 'entries', :action => 'index'
  
  map.entries_search 'entries/search', :controller => 'entries', :action => 'search'
  map.entries_widget 'entries/widget', :controller => 'entries', :action => 'widget'
  map.entry 'entries/:year/:month/:day/:document_number/:slug', :controller => 'entries',
                                                                :action     => 'show',
                                                                :year       => /\d{4}/,
                                                                :month      => /\d{1,2}/,
                                                                :day        => /\d{1,2}/
                                               
  map.entry_citation 'citations/:year/:month/:day/:document_number/:slug', :controller => 'entries',
                                                                                :action     => 'citations',
                                                                                :year       => /\d{4}/,
                                                                                :month      => /\d{1,2}/,
                                                                                :day        => /\d{1,2}/

  map.entries_by_date 'entries/:year/:month/:day', :controller => 'entries',
                                                   :action     => 'by_date',
                                                   :year       => /\d{4}/,
                                                   :month      => /\d{1,2}/,
                                                   :day        => /\d{1,2}/
  map.entries_date_search 'entries/date_search', :controller => 'entries',
                                                 :action     => 'date_search'

  
  map.current_headlines 'entries/current-headlines', :controller => 'entries',
                                                     :action     => 'current_headlines'

  map.short_entry 'e/:document_number', :controller => 'entries',
                                        :action     => 'tiny_pulse'
  
  
  map.citation 'citation/:volume/:page', :controller => 'citations',
                                         :action     => 'show',
                                         :volume     => /\d{2}/,
                                         :page       => /\d+/
  map.citation_search 'citation/search', :controller => 'citations',
                                         :action     => 'search'
  
  # TOPICS
  map.topic_groups_by_letter '/topics/:letter',
      :requirements => {:letter => /[a-z]/},
      :controller => "topic_groups",
      :action => "by_letter"
  
  map.resources :topic_groups, :as => "topics", :only => [:index, :show]
  
  # AGENCIES
  map.resources :agencies, :only => [:index, :show]
  
  # PLACES
  map.maps 'maps', :controller => 'maps',
                   :action     => 'index'
  map.place 'places/:slug/:id.:format', :controller => 'places', :action => 'show'
  
  # LOCATION
  map.resource :location, :only => [:update, :edit], :member => {:congress => :get, :places => :get}

  # SECTIONS
  map.section ':slug', :controller => "sections", :action => "show"
end
