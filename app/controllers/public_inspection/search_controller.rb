class PublicInspection::SearchController < SearchController
  def show
    cache_for 1.day
    respond_to do |wants|
      wants.html
    end
  end

  private
  def load_search
    @search ||= PublicInspectionDocumentSearch.new(params)
  end
end
