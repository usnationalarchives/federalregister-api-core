=begin Schema Information

 Table name: topic_groups

  group_name    :string(255)     primary key
  name          :string(255)
  entries_count :integer(32)

=end Schema Information

class TopicGroup < ActiveRecord::Base
  set_primary_key :group_name
  
  has_many :topics, :foreign_key => :group_name
end
