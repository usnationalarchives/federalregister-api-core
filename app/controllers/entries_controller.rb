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
        @entries = Entry.published_today.preload(:topics, :agencies)
      end
    end
  end
  
  def highlighted
    cache_for 1.day
    respond_to do |wants|
      wants.rss do
        @feed_name = 'Featured Federal Register Articles'
        @entries = Entry.highlighted.preload(:topics, :agencies)
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
    render :layout => false
  end
  
  def show
    cache_for 1.day
    @entry = Entry.find_by_document_number!(params[:document_number])
    
    if @entry.slug != params[:slug]
      redirect_to entry_path(@entry), :status => :moved_permanently
    else
      respond_to do |wants|
        wants.html
      end
    end
  end
  
  def citations
    cache_for 1.day
    @entry = Entry.find_by_document_number!(params[:document_number])
  end
  
  def tiny_url
    cache_for 1.day
    entry = Entry.find_by_document_number!(params[:document_number])
    url = entry_url(entry)
    
    if params[:anchor].present?
      url += '#' + params[:anchor]
    end
    
    redirect_to url, :status=>:moved_permanently
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
    @issue = Issue.find_by_publication_date(@publication_date)
    
    @agencies = Agency.all(
      :include => [:entries],
      :conditions => ['publication_date = ?', @publication_date],
      :order => "agencies.name, entries.title"
    )
    
    Agency.preload_associations(@agencies, :children)
    Entry.preload_associations(@agencies.map(&:entries).flatten, :agencies)
    
    @agencies.each do |agency|
      def agency.entries_excluding_subagency_entries
        self.entries.select{|entry| entry.agencies.excluding_parents.include?(self) }
      end
    end
    
    @entries_without_agency = Entry.all(
      :include => :agencies,
      :conditions => ['agencies.id IS NULL && entries.publication_date = ?', @publication_date],
      :order => "entries.title"
    )
    
    if @agencies.blank? && @entries_without_agency.blank?
      raise ActiveRecord::RecordNotFound
    end
  end
end