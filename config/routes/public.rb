ActionController::Routing::Routes.draw do |map|
  # SPECIAL PAGES
  map.root :controller => 'special', :action => 'home', :conditions => { :method => :get }
  map.connect 'robots.txt', :controller => 'special', :action => 'robots_dot_txt', :format => :txt, :conditions => { :method => :get }

  # ENTRY SEARCH
  map.entries_search 'articles/search.:format', :controller => 'entries/search', :action => 'show', :conditions => { :method => :get }

  # ENTRIES
  if RAILS_ENV == 'development' || RAILS_ENV == 'test'
    map.document_abstract_text 'documents/html/abstract/:id.:format', :controller => 'entries', :action => 'abstract_text', :conditions => {:method => :get}
    map.document_full_text 'documents/html/full_text/:id.:format', :controller => 'entries', :action => 'full_text', :conditions => {:method => :get}
  end

  map.entry 'documents/:year/:month/:day/:document_number/:slug', :controller => 'entries', :conditions => { :method => :get },
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

  # REGULATIONS
  map.regulatory_plan 'regulations/:regulation_id_number/:slug.:format',
                      :controller => 'regulatory_plans',
                      :action     => 'show',
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

  # TOPICS
  map.resources :topics, :as => "topics", :only => [:index, :show], :collection => {:search => :get}
 
  # AGENCIES
  map.resources :agencies, :only => [:index, :show], :collection => {:search => :get}

  # SECTIONS
  map.highlighted_entries_section ":slug/featured.:format", :controller => "sections", :action => "highlighted_entries", :conditions => { :method => :get }
  map.section ':slug.:format', :controller => "sections", :action => "show", :conditions => { :method => :get }
end
