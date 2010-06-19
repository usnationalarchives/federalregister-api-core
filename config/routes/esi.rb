ActionController::Routing::Routes.draw do |map|
  # HOMEPAGE
  map.agency_highlight '/agency_highlight', :controller => 'special', :action => 'agency_highlight'
  
  # ENTRY SEARCH
  map.entries_search_header 'articles/search/header', :controller => 'entries/search', :action => 'header'
  map.entries_search_results 'articles/search/results', :controller => 'entries/search', :action => 'results'
  map.entries_search_facets 'articles/search/facets/:facet', :controller => 'entries/search', :action => 'facets'
  
  # REGULATIONS
  map.regulatory_plan_timeline 'regulations/:regulation_id_number/timeline',
                                :controller => 'regulatory_plans',
                                :action     => 'timeline'
end
