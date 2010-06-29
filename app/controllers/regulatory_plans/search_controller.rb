class RegulatoryPlans::SearchController < SearchController
  private
  
  def load_search
    @search ||= RegulatoryPlanSearch.new(params)
  end
end