class Entries::SearchController < SearchController
  def show
    cache_for 1.day
    if params[:conditions].present? && (params[:conditions].keys - @search.valid_conditions.keys).present?
      redirect_to entries_search_path(
        :conditions => @search.valid_conditions,
        :page => params[:page],
        :order => params[:order],
        :format => params[:format]
      )
      return
    end
    respond_to do |wants|
      wants.html
      wants.rss do
        @feed_name = "Federal Register: Search Results"
        @feed_description = "Federal Register: Search Results"
        @entries = @search.results
        render :template => 'entries/index.rss.builder'
      end
      wants.csv do
        redirect_to api_v1_entries_url(:per_page => 1000, :conditions => params[:conditions], :fields => [:citation, :document_number, :title, :publication_date, :type, :agency_names, :html_url, :page_length], :format => :csv) 
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
      @public_inspection_document_search = PublicInspectionDocumentSearch.new_if_possible(
        :conditions => @search.valid_conditions
      )
    end
    render :layout => false
  end
  
  def activity_sparkline
    chart_options = params.delete(:chart_options)

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

    data = @search.date_distribution(options).counts
    sparkline_data = chart_options.present? ? {:data => data}.merge(chart_options) : {:data => data}
    url = CustomChartHelper::Sparkline.new(sparkline_data).to_s
    c = Curl::Easy.perform(url)
    render :text => c.body_str, :content_type => "image/png" 
    cache_for 1.day
  end

  private
  
  def load_search
    @search ||= EntrySearch.new(params)
  end
end
