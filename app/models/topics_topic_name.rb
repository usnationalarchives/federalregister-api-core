class TopicsTopicName < ApplicationModel
  belongs_to :topic
  belongs_to :topic_name

  after_create :create_topic_assignments
  
  private
    
    def create_topic_assignments
      # SQL for performance
      connection.execute(
        "INSERT INTO topic_assignments (topic_id, entry_id, created_at, updated_at)
         SELECT #{topic_id}, topic_name_assignments.entry_id, NOW(), NOW()
         FROM topic_name_assignments
         WHERE topic_name_assignments.topic_name_id = #{topic_name_id}"
      )
    end
end