=begin Schema Information

 Table name: topic_assignments

  id         :integer(4)      not null, primary key
  topic_id   :integer(4)
  entry_id   :integer(4)
  created_at :datetime
  updated_at :datetime

=end Schema Information

class TopicAssignment < ActiveRecord::Base
  belongs_to :topic
  belongs_to :entry
end
