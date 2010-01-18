=begin Schema Information

 Table name: topic_groups

  group_name             :string(255)     primary key
  name                   :string(255)
  entries_count          :integer(32)
  related_topics_cache   :text
  related_agencies_cache :text

=end Schema Information

class TopicGroup < ActiveRecord::Base
  set_primary_key :group_name
  
  serializable_column :related_topics_cache, :related_agencies_cache
  
  has_many :topics, :foreign_key => :group_name
  
  def to_param
    group_name.gsub(/ |\//, '-')
  end
end
