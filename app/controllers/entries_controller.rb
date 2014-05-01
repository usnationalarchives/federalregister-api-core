class EntriesController < ApplicationController
  def widget
    cache_for 1.day
    params[:per_page] = 5
    params[:order] = :date
    @search = EntrySearch.new(params)
    
    render :layout => 'widget'
  end
  
  def index
    cache_for 1.day
    respond_to do |wants|
      wants.html do
        redirect_to entries_by_date_path(Issue.current.publication_date)
      end
      wants.rss do
        @feed_name = 'Federal Register Latest Entries'
        @entries = EntrySearch.new(:conditions => {:publication_date => {:is => @publication_date}}, :order => "newest", :per_page => 1000).results
      end
    end
  end
  
  def highlighted
    cache_for 1.day
    respond_to do |wants|
      wants.rss do
        @feed_name = 'Featured Federal Register Documents'
        @entries = Entry.highlighted.preload([{:topic_assignments => :topic}, :agencies])
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def date_search
    begin
      date = Date.parse(params[:search] || '', :context => :past).try(:to_date )
    rescue ArgumentError
      render :text => "We couldn't understand that date.", :status => 422
    end
    
    if date.present?
      if Entry.published_on(date).count > 0
        if request.xhr?
          render :text => entries_by_date_path(date)
        else
          redirect_to entries_by_date_url(date)
        end
      else
        render :text => "There is no issue published on #{date}.", :status => 404
      end
    end
  end
  
  def by_date
    cache_for 1.day
    prep_issue_view(parse_date_from_params)
  end
  
  def current_issue
    cache_for 1.day
    prep_issue_view(Issue.current.publication_date)
    @faux_action = "by_date"
    render :action => "by_date"
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
    
    @entry_dates = Entry.all(
      :select => "distinct(publication_date)",
      :conditions => {:publication_date => @date .. @date.end_of_month}
    ).map(&:publication_date)

    @table_class = params[:table_class]

    render :layout => false
  end

  def navigation
    cache_for 1.day
    @issue = Issue.current

    render :partial => 'layouts/navigation/dates', :layout => false
  end
  
  def show
    cache_for 1.day
    
    @entry = Entry.find_by_document_number(params[:document_number])

    if @entry
      if request.path != entry_path(@entry)
        redirect_to entry_path(@entry), :status => :moved_permanently
      else
        render
      end
    else
      @public_inspection_document = PublicInspectionDocument.find_by_document_number!(params[:document_number])
      if request.path != entry_path(@public_inspection_document)
        redirect_to entry_path(@public_inspection_document), :status => :moved_permanently
      else
        render :template => 'public_inspection/show'
      end
    end
  end
  
  def citations
    cache_for 1.day
    @entry = Entry.find_by_document_number!(params[:document_number])
  end
  
  def tiny_url
    cache_for 1.day
    entry_or_pi = Entry.find_by_document_number(params[:document_number]) ||
                  PublicInspectionDocument.find_by_document_number(params[:document_number]) ||
                  ((params[:document_number].to_s.to_i.to_s == params[:document_number].to_s) && Entry.find_by_id(params[:document_number]))
    raise ActiveRecord::RecordNotFound if entry_or_pi.blank?

    respond_to do |wants|
      wants.html do
        url = entry_url(entry_or_pi, params.except(:anchor, :document_number, :action, :controller, :format))
        
        if params[:anchor].present?
          url += '#' + params[:anchor]
        end
        redirect_to url, :status => :moved_permanently
      end
      wants.pdf do
        if entry_or_pi.is_a?(Entry)
          redirect_to entry_or_pi.source_url(:pdf), :status => :moved_permanently
        else
          @public_inspection_document = entry_or_pi
          render :template => "public_inspection/not_published.html.erb",
                 :layout => "application.html.erb",
                 :content_type => 'text/html',
                 :status => :not_found
        end
      end
    end
  end

  def random
    @entry = Entry.random_selection(1).first
    redirect_to entry_url(@entry)
  end

  private
  
  def parse_date_from_params
    year  = params[:year]
    month = params[:month]
    day   = params[:day]
    begin
      Date.parse("#{year}-#{month}-#{day}")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def prep_issue_view(date)
    @publication_date = date
    @issue = Issue.completed.find_by_publication_date!(@publication_date)
    
    toc = TableOfContentsPresenter.new(@issue.entries.scoped(:include => [:agencies, :agency_names]))
    @entries_without_agencies = toc.entries_without_agencies
    @agencies = toc.agencies
  end
end
