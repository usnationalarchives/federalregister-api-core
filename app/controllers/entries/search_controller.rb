class Entries::SearchController < SearchController
  private
  
  def load_search
    @search ||= EntrySearch.new(params)
  end
end