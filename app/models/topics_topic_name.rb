class TopicsTopicName < ApplicationModel
  belongs_to :topic
  belongs_to :topic_name
  has_many :topic_assignments, :dependent => :destroy
  
  after_create :create_topic_assignments
  
  private
  
  def create_topic_assignments
    topic_name.topic_name_assignments.each do |topic_name_assignment|
      topic_name_assignment.entry.topic_assignments << TopicAssignment.new(:topic => topic, :topics_topic_name => self)
    end
  end
end
