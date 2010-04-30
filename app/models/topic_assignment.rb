=begin Schema Information

 Table name: topic_assignments

  id         :integer(4)      not null, primary key
  topic_id   :integer(4)
  entry_id   :integer(4)
  created_at :datetime
  updated_at :datetime

=end Schema Information

class TopicAssignment < ApplicationModel
  belongs_to :topic, :counter_cache => :entries_count
  belongs_to :entry
end
