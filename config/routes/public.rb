FR2::Application.routes.draw do
  # SPECIAL PAGES
  match '/' => 'special#home', :via => :get
  match 'robots.txt' => 'special#robots_dot_txt', :format => :txt, :via => :get

  # ENTRY SEARCH
  match 'articles/search.:format' => 'entries/search#show', :as => :entries_search, :via => :get
  match 'articles/search/help' => 'entries/search#help', :as => :entries_search_help, :via => :get
  match 'articles/search/activity/sparkline/:period' => 'entries/search#activity_sparkline', :as => :entries_search_activity_sparkline, :via => :get

  # ENTRY PAGE VIEW
  match 'articles/views' => 'entries/page_views#create', :as => :entries_page_views, :via => :post

  # ENTRIES
  if RAILS_ENV == 'development' || RAILS_ENV == 'test'
    match 'documents/html/abstract/:id.:format' => 'entries#abstract_text', :as => :document_abstract_text, :via => :get
    match 'documents/html/full_text/:id.:format' => 'entries#full_text', :as => :document_full_text, :via => :get
  end

  match 'articles.:format' => 'entries#index', :as => :entries, :via => :get
  match 'articles/featured.:format' => 'entries#highlighted', :as => :highlighted_entries, :via => :get
  match 'articles/search/facet' => 'entries#search_facet', :as => :entries_search_facet, :via => :get
  match 'articles/widget' => 'entries#widget', :as => :entries_widget, :via => :get
  match 'documents/:year/:month/:day/:document_number/:slug' => 'entries#show', :as => :entry, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :slug => /[^\/]+/, :via => :get
  match 'd/:document_number.:format' => 'entries#tiny_url', :as => :short_entry, :via => :get
  match 'd/:document_number/:anchor' => 'entries#tiny_url', :as => :short_entry_with_anchor, :via => :get
  match 'citations/:year/:month/:day/:document_number/:slug' => 'entries#citations', :as => :entry_citation, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :via => :get
  match 'articles/current' => 'entries#current_issue', :as => :entries_current_issue, :via => :get
  match 'articles/:year/:month/:day' => 'entries#by_date', :as => :entries_by_date, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :via => :get
  match 'articles/date_search' => 'entries#date_search', :as => :entries_date_search, :via => :get
  match 'a/random' => 'entries#random', :as => :random_entry, :via => :get
  match 'a/:document_number.:format' => 'entries#tiny_url', :as => :short_entry, :via => :get
  match 'a/:document_number/:anchor' => 'entries#tiny_url', :as => :short_entry_with_anchor, :via => :get
  match 'executive-orders.:format' => 'executive_orders#index', :as => :executive_orders, :via => :get
  match 'executive-orders/:president/:year.:format' => 'executive_orders#by_president_and_year', :as => :executive_orders_by_president_and_year, :via => :get
  match 'executive-order/:number.:format' => 'executive_orders#show', :as => :executive_order, :number => /\d+/, :via => :get
  match 'citation/:volume/:page' => 'citations#show', :volume => /\d+/, :page => /\d+/, :via => :get
  match 'citation/:fr_citation' => 'citations#show', :as => :citation, :fr_citation => /\d+-FR-\d+/, :via => :get
  match 'citation/search' => 'citations#search', :as => :citation_search, :via => :get

  # ENTRY EMAILS
  match 'articles/email-a-friend/:document_number' => 'entries/emails#new', :as => :new_entry_email, :via => :get
  match 'articles/email-a-friend/:document_number' => 'entries/emails#create', :as => :entry_email, :via => :post
  match 'articles/email-a-friend/:document_number/delivered' => 'entries/emails#delivered', :as => :delivered_entry_email, :via => :get
  match 'public-inspection.:format' => 'public_inspection#index', :as => :public_inspection_documents, :via => :get
  match 'public-inspection/:year/:month/:day' => 'public_inspection#by_date', :as => :public_inspection_documents_by_date, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :via => :get
  match 'public-inspection/search.:format' => 'public_inspection/search#show', :as => :public_inspection_search, :via => :get

  # FR Index
  match 'index' => 'indexes#select_year', :as => :index, :via => :get
  match 'index/:year' => 'indexes#year', :as => :index_year, :via => :get
  match 'index/:year/:agency' => 'indexes#year_agency', :as => :index_year_agency, :via => :get
  match '/select_index_year' => 'indexes#select_year', :as => :select_index_year, :via => :get
  match 'events/search.:format' => 'events/search#show', :as => :events_search, :via => :get
  match 'events/:id.:format' => 'events#show', :as => :event, :via => :get
  resources :topics, :only => [:index, :show] do
    collection do
  get :search
  end
  
  
  end

  match 'topics/:id/significant.:format' => 'topics#significant_entries', :as => :significant_entries_topic, :via => :get
  resources :agencies, :only => [:index, :show] do
    collection do
      get :search
    end
  end

  match 'agencies/:id/significant.:format' => 'agencies#significant_entries', :as => :significant_entries_agency, :via => :get
  match 'regulations/search' => 'regulatory_plans/search#show', :as => :regulatory_plans_search, :via => :get
  match 'regulations/:regulation_id_number/:slug.:format' => 'regulatory_plans#show', :as => :regulatory_plan, :via => :get
  match 'regulations/:regulation_id_number.js' => 'regulatory_plans#json_summary', :format => 'js', :via => :get
  match 'r/:regulation_id_number' => 'regulatory_plans#tiny_url', :as => :short_regulatory_plan, :via => :get

  # EXTERNAL CITATIONS
  # /external-citation/10-CFR-123.456
  match 'external-citation/:year/:citation' => 'external_citations#cfr_citation', :as => :cfr_citation, :constraints => { :citation => /\d+-CFR-\d+(?:\.\d+)?/ }, :via => :get
  match 'select-citation/:year/:month/:day/:citation' => 'external_citations#select_cfr_citation', :as => :select_cfr_citation, :constraints => { :citation => /\d+-CFR-\d+(?:\.\d+)?/ }, :via => :get

  # SECTIONS
  unless ENV["ASSUME_UNITIALIZED_DB"]
    Section.all.each do |section|
      match "#{section.slug}.:format" => "sections#show", :via => :get
      match "#{section.slug}/about" => "sections#about", :via => :get
      match "#{section.slug}/featured.:format" => "sections#highlighted_entries", :via => :get
      match "#{section.slug}/significant.:format" => "sections#significant_entries", :via => :get
    end
  end

  # CANNED SEARCHES
  match ':slug.:format' => 'canned_searches#show', :as => :canned_search, :via => :get

  # SECTIONS
  match ':slug/about' => 'sections#about', :as => :about_section, :via => :get
  match ':slug/featured.:format' => 'sections#highlighted_entries', :as => :highlighted_entries_section, :via => :get
  match ':slug/significant.:format' => 'sections#significant_entries', :as => :significant_entries_section, :via => :get
  match ':slug.:format' => 'sections#show', :as => :section, :via => :get

  # CANNED SEARCHES
  match ':slug.:format' => 'canned_searches#show', :as => :canned_search, :via => :get
end


# ActionController::Routing::Routes.draw do |map|
#   # SPECIAL PAGES
#   map.root :controller => 'special', :action => 'home', :conditions => { :method => :get }
#   map.connect 'robots.txt', :controller => 'special', :action => 'robots_dot_txt', :format => :txt, :conditions => { :method => :get }
#   # map.widget_instructions 'widget_instructions', :controller => 'special', :action => 'widget_instructions', :conditions => { :method => :get }

#   # ENTRY SEARCH
#   map.entries_search 'articles/search.:format', :controller => 'entries/search', :action => 'show', :conditions => { :method => :get }
#   map.entries_search_help 'articles/search/help', :controller => 'entries/search', :action => 'help', :conditions => { :method => :get }
#   map.entries_search_activity_sparkline 'articles/search/activity/sparkline/:period',
#     :controller => 'entries/search',
#     :action => 'activity_sparkline',
#     :conditions => { :method => :get}

#   # ENTRY PAGE VIEW
#   map.entries_page_views 'articles/views', :controller => 'entries/page_views', :action => 'create', :conditions => { :method => :post }

#   # ENTRIES
#   if RAILS_ENV == 'development' || RAILS_ENV == 'test'
#     map.document_abstract_text 'documents/html/abstract/:id.:format', :controller => 'entries', :action => 'abstract_text', :conditions => {:method => :get}
#     map.document_full_text 'documents/html/full_text/:id.:format', :controller => 'entries', :action => 'full_text', :conditions => {:method => :get}
#   end

#   map.entries 'articles.:format', :controller => 'entries', :action => 'index', :conditions => { :method => :get }
#   map.highlighted_entries 'articles/featured.:format', :controller => 'entries', :action => 'highlighted', :conditions => { :method => :get }
#   map.entries_search_facet 'articles/search/facet', :controller => 'entries', :action => 'search_facet', :conditions => { :method => :get }
#   map.entries_widget 'articles/widget', :controller => 'entries', :action => 'widget', :conditions => { :method => :get }
#   map.entry 'documents/:year/:month/:day/:document_number/:slug', :controller => 'entries', :conditions => { :method => :get },
#                                                                 :action     => 'show',
#                                                                 :year       => /\d{4}/,
#                                                                 :month      => /\d{1,2}/,
#                                                                 :day        => /\d{1,2}/,
#                                                                 :slug       => /[^\/]+/
                                                                
#   map.short_entry 'd/:document_number.:format',	
#     :controller => 'entries',	
#     :action     => 'tiny_url',	
#     :conditions => { :method => :get }

#   map.short_entry_with_anchor 'd/:document_number/:anchor',	
#     :controller => 'entries',	
#     :action     => 'tiny_url',	
#     :conditions => { :method => :get }

#   map.entry_citation 'citations/:year/:month/:day/:document_number/:slug', :controller => 'entries',
#                                                                                 :action     => 'citations',
#                                                                                 :conditions => { :method => :get },
#                                                                                 :year       => /\d{4}/,
#                                                                                 :month      => /\d{1,2}/,
#                                                                                 :day        => /\d{1,2}/

#   map.entries_current_issue 'articles/current', :controller => 'entries',
#                                                 :action      => 'current_issue',
#                                                 :conditions => { :method => :get }

#   map.entries_by_date 'articles/:year/:month/:day', :controller => 'entries',
#                                                    :action      => 'by_date',
#                                                    :conditions => { :method => :get },
#                                                    :year        => /\d{4}/,
#                                                    :month       => /\d{1,2}/,
#                                                    :day         => /\d{1,2}/
#   map.entries_date_search 'articles/date_search', :controller => 'entries',
#                                                   :action     => 'date_search',
#                                                   :conditions => { :method => :get }

#   map.random_entry 'a/random', :controller => 'entries',
#                                 :action => 'random',
#                                 :conditions => { :method => :get }
#   map.short_entry 'a/:document_number.:format',
#                                         :controller => 'entries',
#                                         :action     => 'tiny_url',
#                                         :conditions => { :method => :get }

#   map.short_entry_with_anchor 'a/:document_number/:anchor',
#                                         :controller => 'entries',
#                                         :action     => 'tiny_url',
#                                         :conditions => { :method => :get }
#   map.executive_orders 'executive-orders.:format',
#                                         :controller => "executive_orders",
#                                         :action => "index",
#                                         :conditions => {:method => :get}
#   map.executive_orders_by_president_and_year 'executive-orders/:president/:year.:format',
#                                         :controller => "executive_orders",
#                                         :action => "by_president_and_year",
#                                         :conditions => {:method => :get}
#   map.executive_order 'executive-order/:number.:format',
#                                         :controller => "executive_orders",
#                                         :action     => "show",
#                                         :conditions => {:method => :get},
#                                         :number     => /\d+/
#   map.connect 'citation/:volume/:page', :controller => 'citations',
#                                          :action     => 'show',
#                                          :conditions => { :method => :get },
#                                          :volume     => /\d+/,
#                                          :page       => /\d+/
#   map.citation 'citation/:fr_citation', :controller => 'citations',
#                                          :action     => 'show',
#                                          :conditions => { :method => :get },
#                                          :fr_citation => /\d+-FR-\d+/
#   map.citation_search 'citation/search', :controller => 'citations',
#                                          :action     => 'search',
#                                          :conditions => { :method => :get }

#   # ENTRY EMAILS
#   map.new_entry_email 'articles/email-a-friend/:document_number', :controller => "entries/emails",
#                                                                   :action => "new",
#                                                                   :conditions => {:method => :get}
#   map.entry_email 'articles/email-a-friend/:document_number', :controller => "entries/emails",
#                                                               :action => "create",
#                                                               :conditions => {:method => :post}
#   map.delivered_entry_email 'articles/email-a-friend/:document_number/delivered', :controller => "entries/emails",
#                                                                                   :action => "delivered",
#                                                                                   :conditions => {:method => :get}

#   map.public_inspection_documents 'public-inspection.:format',
#                                                    :controller => 'public_inspection',
#                                                    :action => 'index',
#                                                    :conditions => {:method => :get}
#   map.public_inspection_documents_by_date 'public-inspection/:year/:month/:day', :controller => 'public_inspection',
#                                                    :action      => 'by_date',
#                                                    :conditions => { :method => :get },
#                                                    :year        => /\d{4}/,
#                                                    :month       => /\d{1,2}/,
#                                                    :day         => /\d{1,2}/

#   map.public_inspection_search 'public-inspection/search.:format', :controller => 'public_inspection/search', :action => 'show', :conditions => { :method => :get }

#   # FR Index
#   map.index 'index', :controller => "indexes", :action => "select_year", :conditions => {:method => :get}
#   map.index_year 'index/:year', :controller => "indexes", :action => "year", :conditions => {:method => :get}
#   map.index_year_agency 'index/:year/:agency', :controller => "indexes", :action => "year_agency", :conditions => {:method => :get}
#   map.select_index_year '/select_index_year', :controller => "indexes", :action => "select_year", :conditions => {:method => :get}

#   # EVENT SEARCH
#   map.events_search 'events/search.:format', :controller => 'events/search', :action => 'show', :conditions => { :method => :get }

#   # EVENT
#   map.event 'events/:id.:format', :controller => 'events', :action => 'show', :conditions => { :method => :get }

#   # TOPICS
#   map.resources :topics, :as => "topics", :only => [:index, :show], :collection => {:search => :get}
#   map.significant_entries_topic 'topics/:id/significant.:format', :controller => "topics", :action => "significant_entries", :conditions => { :method => :get }

#   # AGENCIES
#   map.resources :agencies, :only => [:index, :show], :collection => {:search => :get}
#   map.significant_entries_agency 'agencies/:id/significant.:format', :controller => "agencies", :action => "significant_entries", :conditions => { :method => :get }

#   # REGULATIONS
#   map.regulatory_plans_search 'regulations/search',
#                       :controller => 'regulatory_plans/search',
#                       :action     => 'show',
#                       :conditions => { :method => :get }
#   map.regulatory_plan 'regulations/:regulation_id_number/:slug.:format',
#                       :controller => 'regulatory_plans',
#                       :action     => 'show',
#                       :conditions => { :method => :get }
#   map.connect 'regulations/:regulation_id_number.js',
#                       :controller => 'regulatory_plans',
#                       :action     => 'json_summary',
#                       :format     => 'js',
#                       :conditions => { :method => :get }
#   map.short_regulatory_plan 'r/:regulation_id_number', :controller => 'regulatory_plans',
#                                                        :action     => 'tiny_url',
#                                                        :conditions => { :method => :get }

#   # EXTERNAL CITATIONS
#   # /external-citation/10-CFR-123.456
#   map.with_options(:controller => 'external_citations', :conditions => {:method => :get}) do |external_citation|
#     external_citation.with_options(:requirements => {:citation => /\d+-CFR-\d+(?:\.\d+)?/}) do |external_cfr_citation|
#       external_cfr_citation.cfr_citation 'external-citation/:year/:citation', :action => :cfr_citation
#       external_cfr_citation.select_cfr_citation 'select-citation/:year/:month/:day/:citation', :action => :select_cfr_citation
#     end
#   end

#   # SECTIONS
#   unless ENV["ASSUME_UNITIALIZED_DB"]
#     Section.all.each do |section|
#       map.with_options :slug => section.slug, :controller => "sections", :conditions => { :method => :get } do |section_map|
#         section_map.connect "#{section.slug}.:format",              :action => "show"
#         section_map.connect "#{section.slug}/about",                :action => "about"
#         section_map.connect "#{section.slug}/featured.:format",     :action => "highlighted_entries"
#         section_map.connect "#{section.slug}/significant.:format",  :action => "significant_entries"
#       end
#     end
#   end

#   # CANNED SEARCHES
#   map.canned_search ":slug.:format", :controller => "canned_searches", :action => :show, :conditions => {:method => :get}

#   # SECTIONS
#   map.about_section ":slug/about", :controller => "sections", :action => "about", :conditions => { :method => :get }
#   map.highlighted_entries_section ":slug/featured.:format", :controller => "sections", :action => "highlighted_entries", :conditions => { :method => :get }
#   map.significant_entries_section ":slug/significant.:format", :controller => "sections", :action => "significant_entries", :conditions => { :method => :get }
#   map.section ':slug.:format', :controller => "sections", :action => "show", :conditions => { :method => :get }

#   # CANNED SEARCHES	
#   map.canned_search ":slug.:format", :controller => "canned_searches", :action => :show, :conditions => {:method => :get}
# end
