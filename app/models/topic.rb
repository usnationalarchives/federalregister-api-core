=begin Schema Information

 Table name: topics

  id         :integer(4)      not null, primary key
  name       :string(255)
  created_at :datetime
  updated_at :datetime

=end Schema Information

class Topic < ActiveRecord::Base
  has_many :topic_assignments
  has_many :topics, :through => :topic_assignments
end
