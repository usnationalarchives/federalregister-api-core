class Events::SearchController < SearchController
  private
  
  def load_search
    @search ||= EventSearch.new(params)
  end
end