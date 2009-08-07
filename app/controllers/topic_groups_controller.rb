class TopicGroupsController < ApplicationController
  def index
    @letters = Topic.connection.select_values("SELECT DISTINCT(LEFT(group_name, 1)) as letter FROM topic_groups ORDER BY letter")
    @popular_topic_groups = TopicGroup.find(:all, :order => 'entries_count DESC', :limit => 100).sort_by(&:name)
  end
  
  def show
    @topic_group = TopicGroup.find_by_name!(params[:id])
    @entries = Entry.find(:all,
        :conditions => {:topics => {:group_name => @topic_group.group_name}},
        :joins => :topics,
        :order => "entries.publication_date DESC",
        :limit => 100)
    
    agencies_and_entry_counts = []
    @entries.group_by(&:agency_id).each do |agency_id, entries|
      next if agency_id.blank?
      agencies_and_entry_counts << [Agency.find(agency_id), entries.size]
    end
    
    @agency_labels = []
    @agency_values = []
    agencies_and_entry_counts.sort_by{|a| a[1]}.reverse[0,10].each do |agency, count|
      @agency_labels << "#{agency.sidebar_name}"
      @agency_values << count
    end

    if @agency_values.sum < @entries.size
      count = (@entries.size - @agency_values.sum)
      @agency_labels << "Other"
      @agency_values << count
    end
    
    @granule_labels = []
    @granule_values = []
    @entries.group_by(&:granule_class).each do |granule_class, entries|
      @granule_labels << granule_class
      @granule_values << entries.size
    end
    
    
  end
  
  def by_letter
    @letter = params[:letter]
    
    @topic_groups = TopicGroup.all(:conditions => ["group_name LIKE ?", "#{@letter}%"], :order => "topic_groups.name")
  end
end