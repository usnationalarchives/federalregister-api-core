class RegulatoryPlanSearch < ApplicationSearch
  attr_accessor :priority_category
  [:agency_ids].each do |attr|
    define_method attr do
      @with[attr]
    end
    
    define_method "#{attr}=" do |val|
      if val.present?
        @with[attr] = val
      end
    end
  end
  
  def model
    RegulatoryPlan
  end
  
  def conditions=(conditions)
    [:agency_ids, :term].each do |attr|
      if conditions[attr].present?
        self.send("#{attr}=", conditions[attr])
      end
    end
  end
  
  def conditions
    conditions = {}
    conditions[:priority_category] = "\"#{@priority_category}\"" if @priority_category.present?
    conditions
  end
  
  def agency_facets
    FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets
  
  def priority_category_facets
    raw_facets = Entry.facets(term,
      :with => with,
      :conditions => conditions.except(:priority_category),
      :match_mode => :extended,
      :facets => [:priority_category]
    )[:priority_category]
    
    search_value_for_this_facet = self.priority_category
    facets = raw_facets.to_a.reverse.reject{|id, count| id == 0}.map do |name, count|
      Facet.new(
        :value      => name, 
        :name       => name,
        :count      => count,
        :on         => name == search_value_for_this_facet.to_s,
        :condition  => :type
      )
    end
  end
  memoize :priority_category_facets
  
  private
  
  def set_defaults(options)
  end
end