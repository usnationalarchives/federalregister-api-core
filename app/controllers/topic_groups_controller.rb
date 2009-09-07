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
        @entries = Entry.find(:all,
            :conditions => {:topics => {:group_name => @topic_group.group_name}},
            :include => :topics,
            :order => "entries.publication_date DESC",
            :limit => 100)
        
        agencies = Agency.all(:select => 'agencies.*, count(*) AS entries_count',
          :joins => {:entries => :topics},
          :conditions => {:entries => {:topics => {:group_name => group_name}}},
          :group => "agencies.id",
          :order => 'entries_count DESC'
        )

        @agency_labels = []
        @agency_values = []
        agencies[0,10].each do |agency|
          @agency_labels << "#{agency.sidebar_name}"
          @agency_values << agency.entries_count
        end

        total_entries = agencies.sum(&:entries_count)
        total_in_top_ten = @agency_values.sum
        if total_in_top_ten < total_entries
          count = (total_entries - total_in_top_ten)
          @agency_labels << "Other"
          @agency_values << count
        end
    
        @granule_labels = []
        @granule_values = []
        
        by_granule_class = Entry.all(
          :select => 'granule_class, count(*) AS count',
          :joins  => :topics,
          :conditions => {:topics => {:group_name => group_name}},
          :group => 'granule_class',
          :order => 'count DESC'
        )
        by_granule_class.each do |summary|
          @granule_labels << summary.granule_class
          @granule_values << summary.count.to_i
        end
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