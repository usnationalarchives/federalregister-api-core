class RegulatoryPlanSearch < ApplicationSearch
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
    # conditions[:type] = @type if @type.present?
    # conditions
  end
  
  def agency_facets
    FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets
  
  private
  
  def set_defaults(options)
  end
end