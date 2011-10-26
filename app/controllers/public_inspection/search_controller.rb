class PublicInspection::SearchController < SearchController
  def show
    cache_for 1.day
    respond_to do |wants|
      wants.html
      wants.rss do
        @documents = @search.results
        @feed_name = @search.summary
        render :template => 'public_inspection/index.rss.builder'
      end
    end
  end

  private
  def load_search
    @search ||= PublicInspectionDocumentSearch.new(params)
  end
end
