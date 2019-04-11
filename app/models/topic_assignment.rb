class TopicAssignment < ApplicationModel
  belongs_to :topic, :counter_cache => :entries_count
  belongs_to :entry
  belongs_to :topics_topic_name
end
