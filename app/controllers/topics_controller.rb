class TopicsController < ApplicationController
  
  def index
    @topics = Topic.find(:all, :order => 'entries_count', :limit => 50)
  end
end