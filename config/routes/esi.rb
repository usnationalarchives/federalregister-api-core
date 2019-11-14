FR2::Application.routes.draw do
  match '/status/api-core/:id' => 'special#status', :as => :status_api_core, :quiet => 'true', :via => :get
  match '/status' => 'special#status', :as => :status, :quiet => 'true', :via => :get

  # LAYOUT
  match '/layout/head_content' => 'special#layout_head_content', :as => :layout_head_content, :quiet => 'true', :via => :get
  match '/layout/header' => 'special#layout_header', :as => :layout_header, :quiet => 'true', :via => :get

  # HOMEPAGE
  match '/agency_highlight' => 'special#agency_highlight', :as => :agency_highlight, :quiet => 'true', :via => :get
  match '/popular_entries' => 'special#popular_entries', :as => :popular_entries, :quiet => 'true', :via => :get
  match '/most_emailed_entries' => 'special#most_emailed_entries', :as => :most_emailed_entries, :quiet => 'true', :via => :get

  # NAVIGATION
  match 'sections/navigation' => 'sections#navigation', :as => :sections_navigation, :quiet => 'true', :via => :get
  match 'agencies/navigation' => 'agencies#navigation', :as => :agencies_navigation, :quiet => 'true', :via => :get
  match 'topics/navigation' => 'topics#navigation', :as => :topics_navigation, :quiet => 'true', :via => :get
  match 'articles/navigation' => 'entries#navigation', :as => :date_navigation, :quiet => 'true', :via => :get
  match 'public_inspection/navigation' => 'public_inspection#navigation', :as => :pi_navigation, :quiet => 'true', :via => :get
  match 'executive_orders/navigation' => 'executive_orders#navigation', :as => :executive_orders_navigation, :quiet => 'true', :via => :get

  # BY DATE
  match 'articles/:year/:month' => 'entries#by_month', :as => :entries_by_month, :quiet => 'true', :year => /\d{4}/, :month => /\d{1,2}/, :via => :get

  # ENTRY SEARCH
  match 'articles/search/header' => 'entries/search#header', :as => :entries_search_header, :quiet => 'true', :via => :get
  match 'articles/search/results.:format' => 'entries/search#results', :as => :entries_search_results, :quiet => 'true', :via => :get
  match 'articles/search/suggestions.:format' => 'entries/search#suggestions', :as => :entries_search_suggestions, :quiet => 'true', :via => :get
  match 'articles/search/facets/:facet' => 'entries/search#facets', :as => :entries_search_facets, :quiet => 'true', :via => :get

  # PI BY DATE
  match 'public-inspection/:year/:month' => 'public_inspection#by_month', :as => :public_inspection_documents_by_month, :quiet => 'true', :year => /\d{4}/, :month => /\d{1,2}/, :via => :get

  # PI SEARCH
  match 'public-inspection/search/header' => 'public_inspection/search#header', :as => :public_inspection_search_header, :quiet => 'true', :via => :get
  match 'public-inspection/search/results.:format' => 'public_inspection/search#results', :as => :public_inspection_search_results, :quiet => 'true', :via => :get
  match 'public-inspection/search/facets/:facet' => 'public_inspection/search#facets', :as => :public_inspection_search_facets, :quiet => 'true', :via => :get

  # EVENT SEARCH
  match 'events/search/header' => 'events/search#header', :as => :event_search_header, :quiet => 'true', :via => :get
  match 'events/search/results' => 'events/search#results', :as => :event_search_results, :quiet => 'true', :via => :get
  match 'events/search/facets/:facet' => 'events/search#facets', :as => :event_search_facets, :quiet => 'true', :via => :get

  # REGULATIONS
  match 'regulations/:regulation_id_number/timeline' => 'regulatory_plans#timeline', :as => :regulatory_plan_timeline, :quiet => 'true', :via => :get

  # REGULATORY PLAN SEARCH
  match 'regulations/search/header' => 'regulatory_plans/search#header', :as => :regulatory_plan_search_header, :quiet => 'true', :via => :get
  match 'regulations/search/results' => 'regulatory_plans/search#results', :as => :regulatory_plan_search_results, :quiet => 'true', :via => :get
  match 'regulations/search/facets/:facet' => 'regulatory_plans/search#facets', :as => :regulatory_plan_search_facets, :quiet => 'true', :via => :get

  # SECTIONS
  match ':slug/popular_entries.:format' => 'sections#popular_entries', :as => :popular_entries_section, :quiet => 'true', :via => :get
  match ':slug/most_emailed_entries.:format' => 'sections#most_emailed_entries', :as => :most_emailed_entries_section, :quiet => 'true', :via => :get
  match ':slug/popular_topics.:format' => 'sections#popular_topics', :as => :popular_topics_section, :quiet => 'true', :via => :get
  match ':slug/featured_agency.:format' => 'sections#featured_agency', :as => :featured_agency_section, :quiet => 'true', :via => :get

  # FR INDEX
  match 'index/:year/:agency/:type' => 'indexes#year_agency_type', :as => :index_year_agency_type, :quiet => 'true', :via => :get
end


# ActionController::Routing::Routes.draw do |map|
#   map.with_options(:quiet => "true", :conditions => {:method => :get}) do |quiet_map|
#     quiet_map.status_api_core '/status/api-core/:id', :controller => "special", :action => "status"
#     quiet_map.status '/status', :controller => "special", :action => "status"

#     # LAYOUT
#     quiet_map.layout_head_content '/layout/head_content', :controller => 'special', :action => 'layout_head_content'
#     quiet_map.layout_header       '/layout/header',       :controller => 'special', :action => 'layout_header'

#     # HOMEPAGE
#     quiet_map.agency_highlight '/agency_highlight', :controller => 'special', :action => 'agency_highlight'
#     quiet_map.popular_entries '/popular_entries', :controller => 'special', :action => 'popular_entries'
#     quiet_map.most_emailed_entries '/most_emailed_entries', :controller => 'special', :action => 'most_emailed_entries'


#     # NAVIGATION
#     quiet_map.sections_navigation         'sections/navigation',          :controller => 'sections',          :action => 'navigation'
#     quiet_map.agencies_navigation         'agencies/navigation',          :controller => 'agencies',          :action => 'navigation'
#     quiet_map.topics_navigation           'topics/navigation',            :controller => 'topics',            :action => 'navigation'
#     quiet_map.date_navigation             'articles/navigation',          :controller => 'entries',           :action => 'navigation'
#     quiet_map.pi_navigation               'public_inspection/navigation', :controller => 'public_inspection', :action => 'navigation'
#     quiet_map.executive_orders_navigation 'executive_orders/navigation',  :controller => 'executive_orders',  :action => 'navigation'

#     # BY DATE
#     quiet_map.entries_by_month 'articles/:year/:month', :controller => 'entries',
#                                                      :action     => 'by_month',
#                                                      :year       => /\d{4}/,
#                                                      :month      => /\d{1,2}/

#     # ENTRY SEARCH
#     quiet_map.entries_search_header 'articles/search/header', :controller => 'entries/search', :action => 'header'
#     quiet_map.entries_search_results 'articles/search/results.:format', :controller => 'entries/search', :action => 'results'
#     quiet_map.entries_search_suggestions 'articles/search/suggestions.:format', :controller => 'entries/search', :action => 'suggestions'
#     quiet_map.entries_search_facets 'articles/search/facets/:facet', :controller => 'entries/search', :action => 'facets'

#     # PI BY DATE
#     quiet_map.public_inspection_documents_by_month 'public-inspection/:year/:month', :controller => 'public_inspection',
#                                                      :action     => 'by_month',
#                                                      :year       => /\d{4}/,
#                                                      :month      => /\d{1,2}/

#     # PI SEARCH
#     quiet_map.public_inspection_search_header 'public-inspection/search/header', :controller => 'public_inspection/search', :action => 'header'
#     quiet_map.public_inspection_search_results 'public-inspection/search/results.:format', :controller => 'public_inspection/search', :action => 'results'
#     quiet_map.public_inspection_search_facets 'public-inspection/search/facets/:facet', :controller => 'public_inspection/search', :action => 'facets'

#     # EVENT SEARCH
#     quiet_map.event_search_header 'events/search/header', :controller => 'events/search', :action => 'header'
#     quiet_map.event_search_results 'events/search/results', :controller => 'events/search', :action => 'results'
#     quiet_map.event_search_facets 'events/search/facets/:facet', :controller => 'events/search', :action => 'facets'

#     # REGULATIONS
#     quiet_map.regulatory_plan_timeline 'regulations/:regulation_id_number/timeline',
#                                   :controller => 'regulatory_plans',
#                                   :action     => 'timeline'

#     # REGULATORY PLAN SEARCH
#     quiet_map.regulatory_plan_search_header 'regulations/search/header', :controller => 'regulatory_plans/search', :action => 'header'
#     quiet_map.regulatory_plan_search_results 'regulations/search/results', :controller => 'regulatory_plans/search', :action => 'results'
#     quiet_map.regulatory_plan_search_facets 'regulations/search/facets/:facet', :controller => 'regulatory_plans/search', :action => 'facets'

#     # SECTIONS
#     quiet_map.popular_entries_section ':slug/popular_entries.:format', :controller => "sections", :action => "popular_entries"
#     quiet_map.most_emailed_entries_section ':slug/most_emailed_entries.:format', :controller => "sections", :action => "most_emailed_entries"
#     quiet_map.popular_topics_section ':slug/popular_topics.:format', :controller => "sections", :action => "popular_topics"
#     quiet_map.featured_agency_section ':slug/featured_agency.:format', :controller => "sections", :action => "featured_agency"

#     # FR INDEX
#     quiet_map.index_year_agency_type 'index/:year/:agency/:type', :controller => "indexes", :action => "year_agency_type", :conditions => {:method => :get}
#   end
# end
