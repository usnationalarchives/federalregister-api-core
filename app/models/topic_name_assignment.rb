class TopicNameAssignment < ApplicationModel
  belongs_to :entry
  belongs_to :topic_name
  
  after_create :create_topic_assignments
  after_destroy :destroy_topic_assignments
  
  private
  def create_topic_assignments
    if topic_name.present?
      topic_name.topics_topic_names.each do |topics_topic_name|
        entry.topic_assignments << TopicAssignment.new(:topic_id => topics_topic_name.topic_id, :topics_topic_name => topics_topic_name)
      end
    end
    true
  end
  
  def destroy_topic_assignments
    if topic_name.present?
      entry.topic_assignments.select{|ta| topic_name.topics_topic_name_ids.include?(ta.topics_topic_name_id)}.each{|ta| ta.destroy }
    end
    true
  end
end
