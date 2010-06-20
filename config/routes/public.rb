ActionController::Routing::Routes.draw do |map|
  # SPECIAL PAGES
  map.root :controller => 'special', :action => 'home'
  map.widget_instructions 'widget_instructions', :controller => 'special', :action => 'widget_instructions'

  # ENTRY SEARCH
  map.entries_search 'articles/search', :controller => 'entries/search', :action => 'show'
  
  # ENTRY PAGE VIEW
  map.entries_page_views 'articles/views', :controller => 'entries/page_views', :action => 'create'
  
  # ENTRIES
  map.entries 'articles.:format', :controller => 'entries', :action => 'index'
  map.entries_search_facet 'articles/search/facet', :controller => 'entries', :action => 'search_facet'
  map.entries_widget 'articles/widget', :controller => 'entries', :action => 'widget'
  map.entry 'articles/:year/:month/:day/:document_number/:slug.:format', :controller => 'entries',
                                                                :action     => 'show',
                                                                :year       => /\d{4}/,
                                                                :month      => /\d{1,2}/,
                                                                :day        => /\d{1,2}/
                                               
  map.entry_citation 'citations/:year/:month/:day/:document_number/:slug', :controller => 'entries',
                                                                                :action     => 'citations',
                                                                                :year       => /\d{4}/,
                                                                                :month      => /\d{1,2}/,
                                                                                :day        => /\d{1,2}/

  map.entries_by_date 'articles/:year/:month/:day', :controller => 'entries',
                                                   :action     => 'by_date',
                                                   :year       => /\d{4}/,
                                                   :month      => /\d{1,2}/,
                                                   :day        => /\d{1,2}/
  map.entries_date_search 'articles/date_search', :controller => 'entries',
                                                 :action     => 'date_search'

  
  map.current_headlines 'articles/current-headlines', :controller => 'entries',
                                                     :action     => 'current_headlines'

  map.short_entry 'a/:document_number', :controller => 'entries',
                                        :action     => 'tiny_url'
  # Backwards compatability, at least for now...
  map.connect 'e/:document_number',     :controller => 'entries',
                                        :action     => 'tiny_url'
  map.short_entry_with_anchor 'a/:document_number/:anchor', :controller => 'entries',
                                        :action     => 'tiny_url'
  
  map.citation 'citation/:volume/:page', :controller => 'citations',
                                         :action     => 'show',
                                         :volume     => /\d{2}/,
                                         :page       => /\d+/
  map.citation_search 'citation/search', :controller => 'citations',
                                         :action     => 'search'
  
  # TOPICS
  map.topics_by_letter '/topics/:letter',
      :requirements => {:letter => /[a-z]/},
      :controller => "topics",
      :action => "by_letter"
  
  map.resources :topics, :as => "topics", :only => [:index, :show]
  
  # AGENCIES
  map.resources :agencies, :only => [:index, :show]
  
  # REGULATIONS
  map.regulatory_plans_search 'regulations/search',
                      :controller => 'regulatory_plans',
                      :action     => 'search'
  map.regulatory_plans_search_facet 'regulations/search/facet', :controller => 'regulatory_plans', :action => 'search_facet'
  map.regulatory_plan 'regulations/:regulation_id_number/:slug',
                      :controller => 'regulatory_plans',
                      :action     => 'show'
  map.short_regulatory_plan 'r/:regulation_id_number', :controller => 'regulatory_plans',
                                             :action     => 'tiny_url'

  # SECTIONS
  map.section ':slug.:format', :controller => "sections", :action => "show"
  map.highlighted_entries_section ':slug/featured.:format', :controller => "sections", :action => "highlighted"
  map.popular_entries_section ':slug/popular.:format', :controller => "sections", :action => "popular"
  map.about_section ':slug/about', :controller => "sections", :action => "about"
end
