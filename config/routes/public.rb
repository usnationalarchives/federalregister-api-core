ActionController::Routing::Routes.draw do |map|
  # SPECIAL PAGES
  map.root :controller => 'special', :action => 'home', :conditions => { :method => :get }
  map.connect 'robots.txt', :controller => 'special', :action => 'robots_dot_txt', :format => :txt, :conditions => { :method => :get }
  # map.widget_instructions 'widget_instructions', :controller => 'special', :action => 'widget_instructions', :conditions => { :method => :get }

  # ENTRY SEARCH
  map.entries_search 'articles/search.:format', :controller => 'entries/search', :action => 'show', :conditions => { :method => :get }
  map.entries_search_help 'articles/search/help', :controller => 'entries/search', :action => 'help', :conditions => { :method => :get }
  map.entries_search_activity_sparkline 'articles/search/activity/sparkline/:period',
    :controller => 'entries/search',
    :action => 'activity_sparkline', 
    :conditions => { :method => :get}
  
  # ENTRY PAGE VIEW
  map.entries_page_views 'articles/views', :controller => 'entries/page_views', :action => 'create', :conditions => { :method => :post }
  
  # ENTRIES
  map.entries 'articles.:format', :controller => 'entries', :action => 'index', :conditions => { :method => :get }
  map.highlighted_entries 'articles/featured.:format', :controller => 'entries', :action => 'highlighted', :conditions => { :method => :get }
  map.entries_search_facet 'articles/search/facet', :controller => 'entries', :action => 'search_facet', :conditions => { :method => :get }
  map.entries_widget 'articles/widget', :controller => 'entries', :action => 'widget', :conditions => { :method => :get }
  map.entry 'articles/:year/:month/:day/:document_number/:slug', :controller => 'entries', :conditions => { :method => :get },
                                                                :action     => 'show',
                                                                :year       => /\d{4}/,
                                                                :month      => /\d{1,2}/,
                                                                :day        => /\d{1,2}/,
                                                                :slug       => /[^\/]+/
                                               
  map.entry_citation 'citations/:year/:month/:day/:document_number/:slug', :controller => 'entries',
                                                                                :action     => 'citations',
                                                                                :conditions => { :method => :get },
                                                                                :year       => /\d{4}/,
                                                                                :month      => /\d{1,2}/,
                                                                                :day        => /\d{1,2}/

  map.entries_current_issue 'articles/current', :controller => 'entries',
                                                :action      => 'current_issue',
                                                :conditions => { :method => :get }
  
  map.entries_by_date 'articles/:year/:month/:day', :controller => 'entries',
                                                   :action      => 'by_date',
                                                   :conditions => { :method => :get },
                                                   :year        => /\d{4}/,
                                                   :month       => /\d{1,2}/,
                                                   :day         => /\d{1,2}/
  map.entries_date_search 'articles/date_search', :controller => 'entries',
                                                  :action     => 'date_search',
                                                  :conditions => { :method => :get }

  map.random_entry 'a/random', :controller => 'entries',
                                :action => 'random',
                                :conditions => { :method => :get } 
  map.short_entry 'a/:document_number.:format',
                                        :controller => 'entries',
                                        :action     => 'tiny_url',
                                        :conditions => { :method => :get }

  map.short_entry_with_anchor 'a/:document_number/:anchor',
                                        :controller => 'entries',
                                        :action     => 'tiny_url',
                                        :conditions => { :method => :get }
  map.executive_orders 'executive-orders.:format',
                                        :controller => "executive_orders",
                                        :action => "index",
                                        :conditions => {:method => :get}
  map.executive_orders_by_president_and_year 'executive-orders/:president/:year.:format',
                                        :controller => "executive_orders",
                                        :action => "by_president_and_year",
                                        :conditions => {:method => :get}
  map.executive_order 'executive-order/:number.:format',
                                        :controller => "executive_orders",
                                        :action     => "show",
                                        :conditions => {:method => :get},
                                        :number     => /\d+/
  map.connect 'citation/:volume/:page', :controller => 'citations',
                                         :action     => 'show',
                                         :conditions => { :method => :get },
                                         :volume     => /\d+/,
                                         :page       => /\d+/
  map.citation 'citation/:fr_citation', :controller => 'citations',
                                         :action     => 'show',
                                         :conditions => { :method => :get },
                                         :fr_citation => /\d+-FR-\d+/
  map.citation_search 'citation/search', :controller => 'citations',
                                         :action     => 'search',
                                         :conditions => { :method => :get }
  
  # ENTRY EMAILS
  map.new_entry_email 'articles/email-a-friend/:document_number', :controller => "entries/emails",
                                                                  :action => "new",
                                                                  :conditions => {:method => :get}
  map.entry_email 'articles/email-a-friend/:document_number', :controller => "entries/emails",
                                                              :action => "create",
                                                              :conditions => {:method => :post}
  map.delivered_entry_email 'articles/email-a-friend/:document_number/delivered', :controller => "entries/emails",
                                                                                  :action => "delivered",
                                                                                  :conditions => {:method => :get}

  map.public_inspection_documents 'public-inspection.:format',
                                                   :controller => 'public_inspection',
                                                   :action => 'index',
                                                   :conditions => {:method => :get}
  map.public_inspection_documents_by_date 'public-inspection/:year/:month/:day', :controller => 'public_inspection',
                                                   :action      => 'by_date',
                                                   :conditions => { :method => :get },
                                                   :year        => /\d{4}/,
                                                   :month       => /\d{1,2}/,
                                                   :day         => /\d{1,2}/

  map.public_inspection_search 'public-inspection/search.:format', :controller => 'public_inspection/search', :action => 'show', :conditions => { :method => :get }

  # FR Index
  map.index 'index', :controller => "indexes", :action => "select_year", :conditions => {:method => :get}
  map.index_year 'index/:year', :controller => "indexes", :action => "year", :conditions => {:method => :get}
  map.index_year_agency 'index/:year/:agency', :controller => "indexes", :action => "year_agency", :conditions => {:method => :get}
  map.select_index_year '/select_index_year', :controller => "indexes", :action => "select_year", :conditions => {:method => :get}

  # EVENT SEARCH
  map.events_search 'events/search.:format', :controller => 'events/search', :action => 'show', :conditions => { :method => :get }
  
  # EVENT
  map.event 'events/:id.:format', :controller => 'events', :action => 'show', :conditions => { :method => :get }
  
  # TOPICS
  map.resources :topics, :as => "topics", :only => [:index, :show], :collection => {:search => :get}
  map.significant_entries_topic 'topics/:id/significant.:format', :controller => "topics", :action => "significant_entries", :conditions => { :method => :get }

  # AGENCIES
  map.resources :agencies, :only => [:index, :show], :collection => {:search => :get}
  map.significant_entries_agency 'agencies/:id/significant.:format', :controller => "agencies", :action => "significant_entries", :conditions => { :method => :get }
  
  # REGULATIONS
  map.regulatory_plans_search 'regulations/search',
                      :controller => 'regulatory_plans/search',
                      :action     => 'show',
                      :conditions => { :method => :get }
  map.regulatory_plan 'regulations/:regulation_id_number/:slug.:format',
                      :controller => 'regulatory_plans',
                      :action     => 'show',
                      :conditions => { :method => :get }
  map.connect 'regulations/:regulation_id_number.js',
                      :controller => 'regulatory_plans',
                      :action     => 'json_summary',
                      :format     => 'js',
                      :conditions => { :method => :get }
  map.short_regulatory_plan 'r/:regulation_id_number', :controller => 'regulatory_plans',
                                                       :action     => 'tiny_url',
                                                       :conditions => { :method => :get }

  # EXTERNAL CITATIONS
  # /external-citation/10-CFR-123.456
  map.with_options(:controller => 'external_citations', :conditions => {:method => :get}) do |external_citation|
    external_citation.with_options(:requirements => {:citation => /\d+-CFR-\d+(?:\.\d+)?/}) do |external_cfr_citation|
      external_cfr_citation.cfr_citation 'external-citation/:year/:citation', :action => :cfr_citation
      external_cfr_citation.select_cfr_citation 'select-citation/:year/:month/:day/:citation', :action => :select_cfr_citation
    end
  end
  
  # SECTIONS
  unless ENV["ASSUME_UNITIALIZED_DB"]
    Section.all.each do |section|
      map.with_options :slug => section.slug, :controller => "sections", :conditions => { :method => :get } do |section_map|
        section_map.connect "#{section.slug}.:format",              :action => "show"
        section_map.connect "#{section.slug}/about",                :action => "about"
        section_map.connect "#{section.slug}/featured.:format",     :action => "highlighted_entries"
        section_map.connect "#{section.slug}/significant.:format",  :action => "significant_entries"
      end
    end
  end
  
  # CANNED SEARCHES
  map.canned_search ":slug.:format", :controller => "canned_searches", :action => :show, :conditions => {:method => :get}
  
  # SECTIONS
  map.about_section ":slug/about", :controller => "sections", :action => "about", :conditions => { :method => :get }
  map.highlighted_entries_section ":slug/featured.:format", :controller => "sections", :action => "highlighted_entries", :conditions => { :method => :get }
  map.significant_entries_section ":slug/significant.:format", :controller => "sections", :action => "significant_entries", :conditions => { :method => :get }
  map.section ':slug.:format', :controller => "sections", :action => "show", :conditions => { :method => :get }
  
end
