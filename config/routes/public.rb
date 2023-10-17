FederalregisterApiCore::Application.routes.draw do
  # SPECIAL PAGES
  root to: 'special#home'
  match '/' => 'special#home', :via => :get

  # ENTRY SEARCH
  match 'articles/search' => 'entries/search#show', :as => :entries_search, :via => :get
  match 'articles/search/help' => 'entries/search#help', :as => :entries_search_help, :via => :get
  match 'articles/search/activity/sparkline/:period' => 'entries/search#activity_sparkline', :as => :entries_search_activity_sparkline, :via => :get

  # ENTRY PAGE VIEW
  match 'articles/views' => 'entries/page_views#create', :as => :entries_page_views, :via => :post

  # ENTRIES
  if RAILS_ENV == 'development' || RAILS_ENV == 'test'
    match 'documents/html/abstract/:id' => 'entries#abstract_text', :as => :document_abstract_text, :via => :get
    match 'documents/html/full_text/:id' => 'entries#full_text', :as => :document_full_text, :via => :get
  end

  match 'articles' => 'entries#index', :as => :entries, :via => :get
  match 'articles/search/facet' => 'entries#search_facet', :as => :entries_search_facet, :via => :get
  match 'articles/widget' => 'entries#widget', :as => :entries_widget, :via => :get
  match 'documents/:year/:month/:day/:document_number/:slug' => 'entries#show', :as => :entry, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :slug => /[^\/]+/, :via => :get
  match 'd/:document_number' => 'entries#tiny_url', :via => :get
  match 'd/:document_number/:anchor' => 'entries#tiny_url', :via => :get
  match 'citations/:year/:month/:day/:document_number/:slug' => 'entries#citations', :as => :entry_citation, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :via => :get
  match 'articles/current' => 'entries#current_issue', :as => :entries_current_issue, :via => :get
  match 'articles/:year/:month/:day' => 'entries#by_date', :as => :entries_by_date, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :via => :get
  match 'articles/date_search' => 'entries#date_search', :as => :entries_date_search, :via => :get
  match 'a/random' => 'entries#random', :as => :random_entry, :via => :get
  match 'a/:document_number' => 'entries#tiny_url', :as => :short_entry, :via => :get
  match 'a/:document_number/:anchor' => 'entries#tiny_url', :as => :short_entry_with_anchor, :via => :get
  match 'executive-orders' => 'executive_orders#index', :as => :executive_orders, :via => :get
  match 'executive-orders/:president/:year' => 'executive_orders#by_president_and_year', :as => :executive_orders_by_president_and_year, :via => :get
  match 'executive-order/:number' => 'executive_orders#show', :as => :executive_order, :number => /\d+/, :via => :get
  match 'citation/:volume/:page' => 'citations#show', :volume => /\d+/, :page => /\d+/, :via => :get
  match 'citation/:fr_citation' => 'citations#show', :as => :citation, :fr_citation => /\d+-FR-\d+/, :via => :get
  match 'citation/search' => 'citations#search', :as => :citation_search, :via => :get

  # ENTRY EMAILS
  match 'articles/email-a-friend/:document_number' => 'entries/emails#new', :as => :new_entry_email, :via => :get
  match 'articles/email-a-friend/:document_number' => 'entries/emails#create', :as => :entry_email, :via => :post
  match 'articles/email-a-friend/:document_number/delivered' => 'entries/emails#delivered', :as => :delivered_entry_email, :via => :get
  match 'public-inspection' => 'public_inspection#index', :as => :public_inspection_documents, :via => :get
  match 'public-inspection/:document_number/:slug' => 'public_inspection_documents#show', :as => :public_inspection_document, :slug => /[^\/]+/, :via => :get
  match 'public-inspection/:year/:month/:day' => 'public_inspection#by_date', :as => :public_inspection_documents_by_date, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :via => :get
  match 'public-inspection/search' => 'public_inspection/search#show', :as => :public_inspection_search, :via => :get

  # FR Index
  match 'index' => 'indexes#select_year', :as => :index, :via => :get
  match 'index/:year' => 'indexes#year', :as => :index_year, :via => :get
  match 'index/:year/:agency' => 'indexes#year_agency', :as => :index_year_agency, :via => :get
  match '/select_index_year' => 'indexes#select_year', :as => :select_index_year, :via => :get
  match 'events/search' => 'events/search#show', :as => :events_search, :via => :get
  match 'events/:id' => 'events#show', :as => :event, :via => :get
  resources :topics, :only => [:index, :show] do
    collection do
      get :search
    end
  end

  match 'topics/:id/significant' => 'topics#significant_entries', :as => :significant_entries_topic, :via => :get
  resources :agencies, :only => [:index, :show] do
    collection do
      get :search
    end
  end

  match 'agencies/:id/significant' => 'agencies#significant_entries', :as => :significant_entries_agency, :via => :get
  match 'regulations/search' => 'regulatory_plans/search#show', :as => :regulatory_plans_search, :via => :get
  match 'regulations/:regulation_id_number/:slug' => 'regulatory_plans#show', :as => :regulatory_plan, :via => :get
  match 'regulations/:regulation_id_number.js' => 'regulatory_plans#json_summary', :format => 'js', :via => :get
  match 'r/:regulation_id_number' => 'regulatory_plans#tiny_url', :as => :short_regulatory_plan, :via => :get

  # EXTERNAL CITATIONS
  # /external-citation/10-CFR-123.456
  match 'external-citation/:year/:citation' => 'external_citations#cfr_citation', :as => :cfr_citation, :constraints => { :citation => /\d+-CFR-\d+(?:\.\d+)?/ }, :via => :get
  match 'select-citation/:year/:month/:day/:citation' => 'external_citations#select_cfr_citation', :as => :select_cfr_citation, :constraints => { :citation => /\d+-CFR-\d+(?:\.\d+)?/ }, :via => :get

  # SECTIONS
  unless true#ENV["ASSUME_UNITIALIZED_DB"]
    Section.all.each do |section|
      match "#{section.slug}" => "sections#show", :via => :get
      match "#{section.slug}/about" => "sections#about", :via => :get
      match "#{section.slug}/significant" => "sections#significant_entries", :via => :get
    end
  end

  # CANNED SEARCHES
  match ':slug' => 'canned_searches#show', :as => :canned_search, :via => :get

  # SECTIONS
  match ':slug/about' => 'sections#about', :as => :about_section, :via => :get
  match ':slug/significant' => 'sections#significant_entries', :as => :significant_entries_section, :via => :get
  match ':slug' => 'sections#show', :as => :section, :via => :get
end
