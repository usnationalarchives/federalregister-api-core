ActionController::Routing::Routes.draw do |map|
  # SPECIAL PAGES
  map.root :controller => 'special', :action => 'home'
  map.widget_instructions 'widget_instructions', :controller => 'special', :action => 'widget_instructions'

  # ENTRY SEARCH
  map.entries_search 'articles/search.:format', :controller => 'entries/search', :action => 'show'
  
  # ENTRY PAGE VIEW
  map.entries_page_views 'articles/views', :controller => 'entries/page_views', :action => 'create'
  
  # ENTRIES
  map.entries 'articles.:format', :controller => 'entries', :action => 'index'
  map.highlighted_entries 'articles/featured.:format', :controller => 'entries', :action => 'highlighted'
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
  
  # EVENT SEARCH
  map.events_search 'events/search.:format', :controller => 'events/search', :action => 'show'
  
  # EVENT
  map.event 'events/:id.:format', :controller => 'events', :action => 'show'
  
  # TOPICS
  map.resources :topics, :as => "topics", :only => [:index, :show]
  map.significant_entries_topic 'topics/:id/significant.:format', :controller => "topics", :action => "significant_entries"

  # AGENCIES
  map.resources :agencies, :only => [:index, :show]
  map.significant_entries_agency 'agencies/:id/significant.:format', :controller => "agencies", :action => "significant_entries"
  
  # REGULATIONS
  map.regulatory_plans_search 'regulations/search',
                      :controller => 'regulatory_plans/search',
                      :action     => 'show'
  map.regulatory_plan 'regulations/:regulation_id_number/:slug',
                      :controller => 'regulatory_plans',
                      :action     => 'show'
  map.short_regulatory_plan 'r/:regulation_id_number', :controller => 'regulatory_plans',
                                             :action     => 'tiny_url'

  # SECTIONS
  Section.all.each do |section|
    map.with_options :slug => section.slug, :controller => "sections" do |section_map|
      section_map.connect "#{section.slug}.:format",              :action => "show"
      section_map.connect "#{section.slug}/about",                :action => "about"
      section_map.connect "#{section.slug}/featured.:format",     :action => "highlighted_entries"
      section_map.connect "#{section.slug}/significant.:format",  :action => "significant_entries"
    end
  end
  
  # page routing
  map.page ':path', :requirements => {:path => /[a-zA-Z_\/-]+/}, :controller => "pages", :action => "show"
  
  # true section routes
  map.about_section ":slug/about", :controller => "sections", :action => "about"
  map.highlighted_entries_section ":slug/featured.:format", :controller => "sections", :action => "highlighted"
  map.significant_entries_section ":slug/significant.:format", :controller => "sections", :action => "significant"
  map.section ':slug.:format', :controller => "sections", :action => "show"
end
