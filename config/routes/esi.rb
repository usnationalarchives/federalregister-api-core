ActionController::Routing::Routes.draw do |map|
  # HOMEPAGE
  map.agency_highlight '/agency_highlight', :controller => 'special', :action => 'agency_highlight'
  
  # ENTRY SEARCH
  map.entries_search_header 'articles/search/header', :controller => 'entries/search', :action => 'header'
  map.entries_search_results 'articles/search/results', :controller => 'entries/search', :action => 'results'
  map.entries_search_facets 'articles/search/facets/:facet', :controller => 'entries/search', :action => 'facets'
  
  # EVENT SEARCH
  map.event_search_header 'events/search/header', :controller => 'events/search', :action => 'header'
  map.event_search_results 'events/search/results', :controller => 'events/search', :action => 'results'
  map.event_search_facets 'events/search/facets/:facet', :controller => 'events/search', :action => 'facets'
  
  # REGULATIONS
  map.regulatory_plan_timeline 'regulations/:regulation_id_number/timeline',
                                :controller => 'regulatory_plans',
                                :action     => 'timeline'
  # SECTIONS
  map.popular_entries_section ':slug/popular_entries.:format', :controller => "sections", :action => "popular_entries"
  map.popular_topics_section ':slug/popular_topics.:format', :controller => "sections", :action => "popular_topics"
end
