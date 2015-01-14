class RegulatoryPlans::SearchController < SearchController
  def show
    cache_for 1.day
  end

  private

  def load_search
    @search ||= RegulatoryPlanSearch.new(params)
  end
end