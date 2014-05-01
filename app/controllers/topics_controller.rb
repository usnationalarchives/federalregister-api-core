class TopicsController < ApplicationController
  def index
    cache_for 1.day
    @topics = Topic.all(:order => "topics.name", :conditions => "topics.entries_count > 0")
  end

  def search
    topics = Topic.named_approximately(params[:term]).limit(10)
    render :json => topics.map{|t| {:id => t.id, :name => t.name, :url => topic_url(t)} }
  end

  def show
    cache_for 1.day
    @topic = Topic.find_by_slug!(params[:id])

    respond_to do |wants|
      wants.html do
        @entries = @topic.entries.most_recent(50)
        @entry_types = Entry.all(
          :select => 'granule_class, count(*) AS count',
          :joins => :topic_assignments,
          :conditions => {:topic_assignments => {:topic_id => @topic.id}},
          :group => 'granule_class',
          :order => 'count DESC'
        )
        
      end
      wants.rss do
        @feed_name = "Federal Register: #{@topic.name}"
        @feed_description = "Recent Federal Register entries about #{@topic.name}."
        @entries = EntrySearch.new(:conditions => {:topic_ids => [@topic.id]}, :order => "newest", :per_page => 20).results
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def significant_entries
    cache_for 1.day
    @topic = Topic.find_by_slug!(params[:id])
    
    respond_to do |wants|
      wants.rss do
        @feed_name = "Federal Register: Significant documents from the '#{@topic.name}' topic"
        @feed_description = "Significant Federal Register documents from the '#{@topic.name}' topic."
        @entries = EntrySearch.new(:conditions => {:significant => 1, :topic_ids => [@topic.id]}, :order => "newest", :per_page => 20).results
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def navigation
    cache_for 1.day

    @topics = Topic.without_routine.top_by_article_count(10).in_last_days(30).sort_by{|t| t.name}
    @issue  = Issue.current
    @date   = Date.current

    render :partial => 'layouts/navigation/topics', :layout => false
  end
end
