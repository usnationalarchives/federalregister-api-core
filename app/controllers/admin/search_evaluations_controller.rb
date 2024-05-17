class Admin::SearchEvaluationsController < AdminController

  def index
    @presenter = SearchEvaluationPresenter.new(k_value: params.dig(:search_evaluations, :k_value))
  end

end
