class EventSearch < ApplicationSearch
  define_filter :agency_ids,  :sphinx_type => :with_all
  define_place_filter :place_id
  
  def agency_facets
    FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets
  
  def model
    Event
  end
  
  private
  
  def set_defaults(options)
  end
end