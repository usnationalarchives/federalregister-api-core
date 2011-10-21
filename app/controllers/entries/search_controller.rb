class Entries::SearchController < SearchController
  def show
    cache_for 1.day
    respond_to do |wants|
      wants.html
      wants.rss do
        @feed_name = "Federal Register: Search Results"
        @feed_description = "Federal Register: Search Results"
        @entries = @search.results
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def help
    cache_for 1.day
    if params[:no_layout]
      render :layout => false
    else
      render
    end
  end
  
  def suggestions
    cache_for 1.day

    if params[:conditions]
      per_page = params[:show_all_pi] ? 250 : 3
      conditions = params[:conditions].merge(:pending_publication => "1")
      @public_inspection_document_search = PublicInspectionDocumentSearch.new_if_possible(
        :conditions => conditions
      )
    end
    render :layout => false
  end
  
  def activity_sparkline
    options = case params[:period]
              when 'weekly'
                {:period => :weekly, :since => 1.year.ago}
              when 'monthly'
                {:period => :monthly, :since => 5.years.ago}
              when 'quarterly'
                {:period => :quarterly}
              else
                raise ActiveRecord::RecordNotFound
              end

    data = @search.date_distribution(options)
    url = CustomChartHelper::Sparkline.new(:data => data).to_s

    cache_for 1.day
    redirect_to URI.escape(url)
  end

  private
  
  def load_search
    @search ||= EntrySearch.new(params)
  end
end
