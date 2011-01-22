ActionController::Routing::Routes.draw do |map|
  # SPECIAL PAGES
  map.root :controller => 'special', :action => 'home', :conditions => { :method => :get }
  # map.widget_instructions 'widget_instructions', :controller => 'special', :action => 'widget_instructions', :conditions => { :method => :get }

  # ENTRY SEARCH
  map.entries_search 'articles/search.:format', :controller => 'entries/search', :action => 'show', :conditions => { :method => :get }
  map.entries_search_help 'articles/search/help', :controller => 'entries/search', :action => 'help', :conditions => { :method => :get }
  
  # ENTRY PAGE VIEW
  map.entries_page_views 'articles/views', :controller => 'entries/page_views', :action => 'create', :conditions => { :method => :post }
  
  # ENTRIES
  map.entries 'articles.:format', :controller => 'entries', :action => 'index', :conditions => { :method => :get }
  map.highlighted_entries 'articles/featured.:format', :controller => 'entries', :action => 'highlighted', :conditions => { :method => :get }
  map.entries_search_facet 'articles/search/facet', :controller => 'entries', :action => 'search_facet', :conditions => { :method => :get }
  map.entries_widget 'articles/widget', :controller => 'entries', :action => 'widget', :conditions => { :method => :get }
  map.entry 'articles/:year/:month/:day/:document_number/:slug.:format', :controller => 'entries', :conditions => { :method => :get },
                                                                :action     => 'show',
                                                                :year       => /\d{4}/,
                                                                :month      => /\d{1,2}/,
                                                                :day        => /\d{1,2}/
                                               
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

  
  map.current_headlines 'articles/current-headlines', :controller => 'entries',
                                                      :action     => 'current_headlines',
                                                      :conditions => { :method => :get }

  map.short_entry 'a/:document_number', :controller => 'entries',
                                        :action     => 'tiny_url',
                                        :conditions => { :method => :get }
  # Backwards compatability, at least for now...
  map.connect 'e/:document_number',     :controller => 'entries',
                                        :action     => 'tiny_url',
                                        :conditions => { :method => :get }
  map.short_entry_with_anchor 'a/:document_number/:anchor',
                                        :controller => 'entries',
                                        :action     => 'tiny_url',
                                        :conditions => { :method => :get }
  
  map.citation 'citation/:volume/:page', :controller => 'citations',
                                         :action     => 'show',
                                         :conditions => { :method => :get },
                                         :volume     => /\d{2}/,
                                         :page       => /\d+/
  map.citation_search 'citation/search', :controller => 'citations',
                                         :action     => 'search',
                                         :conditions => { :method => :get }
  
  # EVENT SEARCH
  map.events_search 'events/search.:format', :controller => 'events/search', :action => 'show', :conditions => { :method => :get }
  
  # EVENT
  map.event 'events/:id.:format', :controller => 'events', :action => 'show', :conditions => { :method => :get }
  
  # TOPICS
  map.resources :topics, :as => "topics", :only => [:index, :show]
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

  # SECTIONS
  Section.all.each do |section|
    map.with_options :slug => section.slug, :controller => "sections", :conditions => { :method => :get } do |section_map|
      section_map.connect "#{section.slug}.:format",              :action => "show"
      section_map.connect "#{section.slug}/about",                :action => "about"
      section_map.connect "#{section.slug}/featured.:format",     :action => "highlighted_entries"
      section_map.connect "#{section.slug}/significant.:format",  :action => "significant_entries"
    end
  end
  
  # SUBSCRIPTIONS
  map.resources :subscriptions, :only => [:new, :create, :destroy], :member => {:delete => :get} do |subscription|
    subscription.resource :confirmation, :controller => "subscriptions/confirmations"
  end
  
  # page routing
  map.page ':path', :requirements => {:path => /[a-zA-Z_\/-]+/}, :controller => "pages", :action => "show", :conditions => { :method => :get }
  
  # true section routes
  map.about_section ":slug/about", :controller => "sections", :action => "about", :conditions => { :method => :get }
  map.highlighted_entries_section ":slug/featured.:format", :controller => "sections", :action => "highlighted_entries", :conditions => { :method => :get }
  map.significant_entries_section ":slug/significant.:format", :controller => "sections", :action => "significant_entries", :conditions => { :method => :get }
  map.section ':slug.:format', :controller => "sections", :action => "show", :conditions => { :method => :get }
end
