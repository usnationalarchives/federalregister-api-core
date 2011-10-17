# == Schema Information
#
# Table name: topic_assignments
#
#  id                   :integer(4)      not null, primary key
#  topic_id             :integer(4)
#  entry_id             :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  topics_topic_name_id :integer(4)
#

class TopicAssignment < ApplicationModel
  belongs_to :topic, :counter_cache => :entries_count
  belongs_to :entry
  belongs_to :topics_topic_name
end
