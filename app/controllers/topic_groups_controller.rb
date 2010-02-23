class TopicGroupsController < ApplicationController
  
  def index
    redirect_to topic_groups_by_letter_url('a')
  end
  
  def show
    group_name = params[:id]
    group_name.gsub!(/_|-/, ' ')
    @topic_group = TopicGroup.find_by_group_name!(params[:id])

    respond_to do |wants|
      wants.html do
        @most_cited_entries = Entry.all(
          :conditions => ["topics.group_name = ? AND entries.citing_entries_count > 0", @topic_group.group_name],
          :joins => :topics,
          :order => "citing_entries_count DESC, publication_date DESC",
          :limit => 50
        )
        @entries = Entry.find(:all,
            :conditions => {:topics => {:group_name => @topic_group.group_name}},
            :include => :topics,
            :order => "entries.publication_date DESC",
            :limit => 50)
        @entry_types = Entry.all(
          :select => 'granule_class, count(*) AS count',
          :joins  => :topics,
          :conditions => {:topics => {:group_name => group_name}},
          :group => 'granule_class',
          :order => 'count DESC'
        )
        
      end
      wants.rss do
        @feed_name = "govpulse: #{@topic_group.name}"
        @feed_description = "Recent Federal Register entries about #{@topic_group.name}."
        @entries = Entry.find(:all,
            :conditions => {:topics => {:group_name => @topic_group.group_name}},
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
    
    @popular_topic_groups = TopicGroup.find(:all, :order => 'entries_count DESC', :limit => 100).sort_by(&:name)
    
    @topic_groups = TopicGroup.all(:conditions => ["group_name LIKE ?", "#{@letter}%"], :order => "topic_groups.name")
  end
end