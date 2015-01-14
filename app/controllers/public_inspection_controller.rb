class PublicInspectionController < ApplicationController
  def index
    cache_for 1.day

    respond_to do |wants|
      wants.html do
        display_issue(PublicInspectionIssue.latest_publication_date)
      end

      wants.rss do
        @documents = PublicInspectionIssue.
          published.
          first(:order => "publication_date DESC").
          public_inspection_documents.
          scoped(:conditions => "publication_date IS NOT NULL")
        @feed_name = 'Most Recent Public Inspection Documents'
        @feed_description = 'All documents currently on Public Inspection at the Office of the Federal Register'
        render :template => 'public_inspection/index.rss.builder'
      end
    end
  end

  def by_date
    cache_for 1.day

    display_issue(parse_date_from_params)
  end

  def by_month
    cache_for 1.day

    begin
      @date = Date.parse("#{params[:year]}-#{params[:month]}-01")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end

    if params[:current_date]
      @current_date = Date.parse(params[:current_date])
    end

    @public_inspection_dates = PublicInspectionIssue.published.all(
      :conditions => {:publication_date => @date.beginning_of_day .. @date.end_of_month.end_of_day}
    ).map(&:publication_date)
    render :layout => false
  end

  def navigation
    cache_for 1.day

    @issue = PublicInspectionIssue.current
    @special_documents = TableOfContentsPresenter.new(@issue.public_inspection_documents.special_filing, :always_include_parent_agencies => true)
    @regular_documents = TableOfContentsPresenter.new(@issue.public_inspection_documents.regular_filing, :always_include_parent_agencies => true)

    render :partial => 'layouts/navigation/public_inspection', :layout => false
  end

  private

  def display_issue(date)
    @faux_controller = "entries"
    @faux_action     = "by_date"

    @date = date
    @issue = PublicInspectionIssue.published.find_by_publication_date!(@date)
    @special_documents = TableOfContentsPresenter.new(@issue.public_inspection_documents.special_filing.scoped(:include => :docket_numbers), :always_include_parent_agencies => true)
    @regular_documents = TableOfContentsPresenter.new(@issue.public_inspection_documents.regular_filing.scoped(:include => :docket_numbers), :always_include_parent_agencies => true)
    render :action => :by_date
  end
end
