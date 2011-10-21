class EventSearch < ApplicationSearch
  define_date_filter :date, :label => "Date"
  define_filter :agency_ids,  :sphinx_type => :with_all
  define_place_filter :near, :sphinx_attribute => :place_id
  define_filter :type do |type|
    Event::EVENT_TYPES_PLURAL[type]
  end
  
  def agency_facets
    FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets
  
  def type_facets
    raw_facets = Event.facets(term,
      :with => with,
      :with_all => with_all,
      :conditions => sphinx_conditions,
      :match_mode => :extended,
      :facets => [:type]
    )[:type]
    
    search_value_for_this_facet = self.type
    facets = raw_facets.to_a.reverse.reject{|id, count| id == 0}.map do |id, count|
      Facet.new(
        :value      => id, 
        :name       => Event::EVENT_TYPES_PLURAL[id],
        :count      => count,
        :on         => id.to_s == search_value_for_this_facet.to_s,
        :condition  => :type
      )
    end
  end
  memoize :type_facets
  
  def supported_orders
    %w(Relevant Newest Oldest)
  end
  
  def order_clause
    case @order
    when 'newest'
      "date DESC, @relevance DESC"
    when 'oldest'
      "date ASC, @relevance DESC"
    else
      "@relevance DESC, date DESC"
    end
  end
  
  def model
    Event
  end
  
  private
  
  def set_defaults(options)
    @order = options[:order] || 'newest'
  end
end
