ActionController::Routing::Routes.draw do |map|
  map.with_options(:quiet => true) do |quiet_map|
    # HOMEPAGE
    quiet_map.agency_highlight '/agency_highlight', :controller => 'special', :action => 'agency_highlight'
    quiet_map.popular_entries '/popular_entries', :controller => 'special', :action => 'popular_entries'
    
    # ENTRY SEARCH
    quiet_map.entries_search_header 'articles/search/header', :controller => 'entries/search', :action => 'header'
    quiet_map.entries_search_results 'articles/search/results', :controller => 'entries/search', :action => 'results'
    quiet_map.entries_search_facets 'articles/search/facets/:facet', :controller => 'entries/search', :action => 'facets'
    
    # EVENT SEARCH
    quiet_map.event_search_header 'events/search/header', :controller => 'events/search', :action => 'header'
    quiet_map.event_search_results 'events/search/results', :controller => 'events/search', :action => 'results'
    quiet_map.event_search_facets 'events/search/facets/:facet', :controller => 'events/search', :action => 'facets'
    
    # REGULATIONS
    quiet_map.regulatory_plan_timeline 'regulations/:regulation_id_number/timeline',
                                  :controller => 'regulatory_plans',
                                  :action     => 'timeline'
    
    # REGULATORY PLAN SEARCH
    quiet_map.regulatory_plan_search_header 'regulations/search/header', :controller => 'regulatory_plans/search', :action => 'header'
    quiet_map.regulatory_plan_search_results 'regulations/search/results', :controller => 'regulatory_plans/search', :action => 'results'
    quiet_map.regulatory_plan_search_facets 'regulations/search/facets/:facet', :controller => 'regulatory_plans/search', :action => 'facets'
    
    # SECTIONS
    quiet_map.popular_entries_section ':slug/popular_entries.:format', :controller => "sections", :action => "popular_entries"
    quiet_map.popular_topics_section ':slug/popular_topics.:format', :controller => "sections", :action => "popular_topics"
  end
end
