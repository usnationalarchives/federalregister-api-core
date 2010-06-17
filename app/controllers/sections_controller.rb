class SectionsController < ApplicationController
  include Shared::SectionsControllerUtilities
  
  def show
    prepare_for_show(params[:slug], Entry.latest_publication_date)
    @preview = false
    respond_to do |wants|
      wants.html do
        @agency = Agency.with_logo.find(:all,
                              :select => "agencies.*, count(entries.id) AS num_entries_this_month",
                              :joins => {:entries => :sections},
                              :conditions => {
                                :sections => {:id => @section.id},
                                :entries => {:publication_date => (1.month.ago .. Date.today)}
                              },
                              :group => "entries.id",
                              :order => "num_entries_this_month DESC",
                              :limit => 10
        ).sort_by { rand }.first
        render :action => :show
      end
      
      wants.rss do
        @feed_name = "Federal Register: #{@section.title} Section"
        @feed_description = "Most Recent Federal Register articles from #{@section.title} Section."
        @entries = @section.entries.published_on(@publication_date)
        render :template => 'entries/index.rss.builder'
      end
      
    end
  end
  
  def about
    @section = Section.find_by_slug!(params[:slug])
  end
  
  def highlighted
    @section = Section.find_by_slug!(params[:slug])
    
    respond_to do |wants|
      wants.rss do
        @feed_name = "Federal Register: Featured articles from the #{@section.title} Section"
        @feed_description = "Featured Federal Register articles from #{@section.title} Section."
        @entries = @section.highlighted_entries
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def popular
    @section = Section.find_by_slug!(params[:slug])
    
    respond_to do |wants|
      wants.html do
        @entries = @section.entries.popular(5)
        render :layout => false
      end
      
      wants.rss do
        @entries = @section.entries.popular(10)
        @feed_name = "Federal Register: Popular articles from the #{@section.title} Section"
        @feed_description = "Popular Federal Register articles from #{@section.title} Section."
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
end