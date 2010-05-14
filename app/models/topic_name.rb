class TopicName < ApplicationModel
  has_many :topic_name_assignments
  has_many :entries, :through => :topic_name_assignments
  
  has_many :topics_topic_names
  has_many :topics, :through => :topics_topic_names
  
  named_scope :unprocessed, :conditions => {:processed_at => nil}
  
  def processed?
    processed_at.present?
  end
end