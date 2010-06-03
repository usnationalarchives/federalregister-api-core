class TopicsController < ApplicationController
  
  def index
    redirect_to topics_by_letter_url('a')
  end
  
  def show
    @topic = Topic.find_by_slug!(params[:id])

    respond_to do |wants|
      wants.html do
        @most_cited_entries = Entry.all(
          :conditions => ["topics.slug = ? AND entries.citing_entries_count > 0", @topic.slug],
          :joins => :topics,
          :order => "citing_entries_count DESC, publication_date DESC",
          :limit => 50
        )
        @entries = Entry.find(:all,
            :conditions => {:topics => {:slug => @topic.slug}},
            :include => :topics,
            :order => "entries.publication_date DESC",
            :limit => 50)
        @entry_types = Entry.all(
          :select => 'granule_class, count(*) AS count',
          :joins  => :topics,
          :conditions => {:topics => {:id => @topic.id}},
          :group => 'granule_class',
          :order => 'count DESC'
        )
        
      end
      wants.rss do
        @feed_name = "Federal Register: #{@topic.name}"
        @feed_description = "Recent Federal Register entries about #{@topic.name}."
        @entries = Entry.find(:all,
            :conditions => {:topics => {:slug => @topic.slug}},
            :joins => [:topics],
            :include => :agency,
            :order => "entries.publication_date DESC",
            :limit => 20)
        render :template => 'entries/index.rss.builder'
      end
    end
  end
  
  def by_letter
    @letter = params[:letter]
    @letters = ('a' .. 'z')
    
    @popular_topics = Topic.find(:all, :order => 'entries_count DESC', :limit => 100).sort_by(&:name)
    
    @topics = Topic.all(:conditions => ["slug LIKE ?", "#{@letter}%"], :order => "topics.name")
  end
end