=begin Schema Information

 Table name: topic_name_assignments

  id            :integer(4)      not null, primary key
  entry_id      :integer(4)
  topic_name_id :integer(4)
  created_at    :datetime
  updated_at    :datetime

=end Schema Information

class TopicNameAssignment < ApplicationModel
  belongs_to :entry
  belongs_to :topic_name
end
