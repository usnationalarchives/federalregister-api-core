class RegulatoryPlanSearch < EsApplicationSearch
  define_filter :agency_ids,  :es_type => :with_all

  def agency_facets
    ApplicationSearch::FacetCalculator.new(:search => self, :model => Agency, :facet_name => :agency_ids).all
  end
  memoize :agency_facets

  define_filter :priority_category, :phrase => true do |val|
    val
  end

  def priority_category_facets
    raw_facets = RegulatoryPlan.facets(term,
      :with => with,
      :with_all => with_all,
      :conditions => es_conditions,
      :match_mode => :extended,
      :facets => [:priority_category]
    )[:priority_category]

    search_value_for_this_facet = self.priority_category
    facets = raw_facets.to_a.reverse.reject{|id, count| id == 0}.map do |name, count|
      ApplicationSearch::Facet.new(
        :value      => name,
        :name       => name,
        :count      => count,
        :on         => name == search_value_for_this_facet.to_s,
        :condition  => :priority_category
      )
    end
  end
  memoize :priority_category_facets

  def model
    RegulatoryPlan
  end

  def find_options
    {
      :include => [:agencies, :agency_names],
    }
  end

  private

  def set_defaults(options)
  end
end
