ActionController::Routing::Routes.draw do |map|
  map.with_options(:quiet => "true", :conditions => {:method => :get}) do |quiet_map|
    quiet_map.status '/status', :controller => "special", :action => "status"
    
    # LAYOUT
    quiet_map.layout_head_content '/layout/head_content', :controller => 'special', :action => 'layout_head_content'
    quiet_map.layout_header       '/layout/header',       :controller => 'special', :action => 'layout_header'
    quiet_map.layout_footer       '/layout/footer',       :controller => 'special', :action => 'layout_footer'
    
    # HOMEPAGE
    quiet_map.agency_highlight '/agency_highlight', :controller => 'special', :action => 'agency_highlight'
    quiet_map.popular_entries '/popular_entries', :controller => 'special', :action => 'popular_entries'
    quiet_map.most_emailed_entries '/most_emailed_entries', :controller => 'special', :action => 'most_emailed_entries'
   

    # NAVIGATION
    quiet_map.sections_navigation         'sections/navigation',          :controller => 'sections',          :action => 'navigation'
    quiet_map.agencies_navigation         'agencies/navigation',          :controller => 'agencies',          :action => 'navigation'
    quiet_map.topics_navigation           'topics/navigation',            :controller => 'topics',            :action => 'navigation'
    quiet_map.date_navigation             'articles/navigation',          :controller => 'entries',           :action => 'navigation'
    quiet_map.pi_navigation               'public_inspection/navigation', :controller => 'public_inspection', :action => 'navigation'
    quiet_map.executive_orders_navigation 'executive_orders/navigation',  :controller => 'executive_orders',  :action => 'navigation'

    # BY DATE
    quiet_map.entries_by_month 'articles/:year/:month', :controller => 'entries',
                                                     :action     => 'by_month',
                                                     :year       => /\d{4}/,
                                                     :month      => /\d{1,2}/
         
    # ENTRY SEARCH
    quiet_map.entries_search_header 'articles/search/header', :controller => 'entries/search', :action => 'header'
    quiet_map.entries_search_results 'articles/search/results.:format', :controller => 'entries/search', :action => 'results'
    quiet_map.entries_search_suggestions 'articles/search/suggestions.:format', :controller => 'entries/search', :action => 'suggestions'
    quiet_map.entries_search_facets 'articles/search/facets/:facet', :controller => 'entries/search', :action => 'facets'
    
    # PI BY DATE
    quiet_map.public_inspection_documents_by_month 'public-inspection/:year/:month', :controller => 'public_inspection',
                                                     :action     => 'by_month',
                                                     :year       => /\d{4}/,
                                                     :month      => /\d{1,2}/
    
    # PI SEARCH
    quiet_map.public_inspection_search_header 'public-inspection/search/header', :controller => 'public_inspection/search', :action => 'header'
    quiet_map.public_inspection_search_results 'public-inspection/search/results', :controller => 'public_inspection/search', :action => 'results'
    quiet_map.public_inspection_search_facets 'public-inspection/search/facets/:facet', :controller => 'public_inspection/search', :action => 'facets'

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
    quiet_map.most_emailed_entries_section ':slug/most_emailed_entries.:format', :controller => "sections", :action => "most_emailed_entries"
    quiet_map.popular_topics_section ':slug/popular_topics.:format', :controller => "sections", :action => "popular_topics"
    quiet_map.featured_agency_section ':slug/featured_agency.:format', :controller => "sections", :action => "featured_agency"

    # FR INDEX
    quiet_map.index_year_agency_type 'index/:year/:agency/:type', :controller => "indexes", :action => "year_agency_type", :conditions => {:method => :get}
  end
end
