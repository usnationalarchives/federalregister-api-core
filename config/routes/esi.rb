FederalregisterApiCore::Application.routes.draw do
  match '/alive' => 'special#alive', :as => :alive, :quiet => 'true', :via => :get
  match '/status/api-core/' => 'special#status', :quiet => 'true', :via => :get
  match '/status' => 'special#status', :as => :status, :quiet => 'true', :via => :get

  # LAYOUT
  match '/layout/head_content' => 'special#layout_head_content', :as => :layout_head_content, :quiet => 'true', :via => :get
  match '/layout/header' => 'special#layout_header', :as => :layout_header, :quiet => 'true', :via => :get

  # HOMEPAGE
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
  match 'articles/search/results' => 'entries/search#results', :as => :entries_search_results, :quiet => 'true', :via => :get
  match 'articles/search/suggestions' => 'entries/search#suggestions', :as => :entries_search_suggestions, :quiet => 'true', :via => :get
  match 'articles/search/facets/:facet' => 'entries/search#facets', :as => :entries_search_facets, :quiet => 'true', :via => :get

  # PI BY DATE
  match 'public-inspection/:year/:month' => 'public_inspection#by_month', :as => :public_inspection_documents_by_month, :quiet => 'true', :year => /\d{4}/, :month => /\d{1,2}/, :via => :get

  # PI SEARCH
  match 'public-inspection/search/header' => 'public_inspection/search#header', :as => :public_inspection_search_header, :quiet => 'true', :via => :get
  match 'public-inspection/search/results' => 'public_inspection/search#results', :as => :public_inspection_search_results, :quiet => 'true', :via => :get
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
  match ':slug/popular_entries' => 'sections#popular_entries', :as => :popular_entries_section, :quiet => 'true', :via => :get
  match ':slug/most_emailed_entries' => 'sections#most_emailed_entries', :as => :most_emailed_entries_section, :quiet => 'true', :via => :get
  match ':slug/popular_topics' => 'sections#popular_topics', :as => :popular_topics_section, :quiet => 'true', :via => :get
  match ':slug/featured_agency' => 'sections#featured_agency', :as => :featured_agency_section, :quiet => 'true', :via => :get

  # FR INDEX
  match 'index/:year/:agency/:type' => 'indexes#year_agency_type', :as => :index_year_agency_type, :quiet => 'true', :via => :get
end
