class TopicGroupsController < ApplicationController
  def index
    redirect_to topic_groups_by_letter_url('a')
  end
  
  def show
    @topic_group = TopicGroup.find(params[:id])
    @entries = Entry.find(:all,
        :conditions => {:topics => {:group_name => @topic_group.group_name}},
        :joins => :topics,
        :order => "entries.publication_date DESC",
        :limit => 100)
  end
  
  def by_letter
    @letter = params[:letter]
    @letters = ('a' .. 'z')
    
    @popular_topic_groups = TopicGroup.find(:all, :order => 'entries_count DESC', :limit => 100).sort_by(&:name)
    
    @topic_groups = TopicGroup.all(:conditions => ["group_name LIKE ?", "#{@letter}%"], :order => "topic_groups.name")
  end
end