class TopicGroupsController < ApplicationController
  def index
    @topics = TopicGroup.find(:all, :order => 'entries_count', :limit => 50)
  end
  
  def show
    @topic_group = TopicGroup.find(params[:id])
    @entries = Entry.find(:all,
        :conditions => {:topics => {:group_name => @topic_group.group_name}},
        :joins => :topics,
        :order => "entries.publication_date DESC",
        :limit => 100)
  end
end