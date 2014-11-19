class SectionsController < ApplicationController
  include Shared::SectionsControllerUtilities
  
  def show
    cache_for 1.day
    
    prepare_for_show(params[:slug], IssueApproval.latest_publication_date)
    @preview = false
    
    respond_to do |wants|
      wants.html
      
      wants.rss do
        @feed_name = "Federal Register: '#{@section.title}' Section"
        @feed_description = "Most Recent Federal Register documents from the '#{@section.title}' Section."
        @entries = EntrySearch.new(:conditions => {:publication_date => {:is => @publication_date}, :section_ids => [@section.id]}, :order => "newest", :per_page => 1000).results
        
        render :template => 'entries/index.rss.builder'
      end
      
    end
  end

  def navigation
    cache_for 1.day

    @issue = Issue.current 
    @date  = Date.current

    render :partial => 'layouts/navigation/sections', :layout => false
  end
  
  def featured_agency
    cache_for 5.minutes
    @section = Section.find_by_slug!(params[:slug])
    @agency = Agency.with_logo.find(:all,
                          :select => "agencies.*, count(entries.id) AS num_entries_this_month",
                          :joins => {:entries => :sections},
                          :conditions => {
                            :sections => {:id => @section.id},
                            :entries => {:publication_date => (1.month.ago .. 1.week.from_now.to_date)}
                          },
                          :group => "entries.id",
                          :order => "num_entries_this_month DESC",
                          :limit => 10
    ).sort_by { rand }.first

    if @agency
      @search = EntrySearch.new(
        :conditions => {
            :agency_ids => [@agency.id],
            :section_ids => [@section.id],
            :publication_date => {:gte => 1.month.ago.to_date.to_s}
        },
        :order => "newest"
      )
      render :layout => false
    else
      render( :nothing => true)
    end
  end
  
  def about
    cache_for 1.day
    @section = Section.find_by_slug!(params[:slug])
  end
  
  def highlighted_entries
    cache_for 1.day
    @section = Section.find_by_slug!(params[:slug])
    
    respond_to do |wants|
      wants.rss do
        @feed_name = "Federal Register: Featured documents from the '#{@section.title}' Section"
        @feed_description = "Featured Federal Register documents from the '#{@section.title}' Section."
        @entries = @section.highlighted_entries.preload([{:topic_assignments => :topic}, :agencies])
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def significant_entries
    cache_for 1.day
    @section = Section.find_by_slug!(params[:slug])
    
    respond_to do |wants|
      wants.rss do
        @feed_name = "Federal Register: Significant documents from the '#{@section.title}' Section"
        @feed_description = "Significant Federal Register documents from the '#{@section.title}' Section."
        @entries = EntrySearch.new(:conditions => {:significant => 1, :section_ids => [@section.id]}, :order => "newest", :per_page => 20).results
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def popular_entries
    cache_for 1.hour
    @section = Section.find_by_slug!(params[:slug])
    @entries = @section.entries.popular.limit(5)
    
    render :template => "entries/popular", :layout => false
  end
  
  def most_emailed_entries
    cache_for 1.hour
    @section = Section.find_by_slug!(params[:slug])
    @entries = @section.entries.most_emailed.limit(5)
    
    render :template => "entries/most_emailed", :layout => false
  end
  
  def popular_topics
    cache_for 1.hour
    @section = Section.find_by_slug!(params[:slug])
    @topics = @section.popular_topics.limit(5)
    
    render :layout => false
  end
  
end
