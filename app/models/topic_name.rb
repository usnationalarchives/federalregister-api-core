class TopicName < ApplicationModel
  has_many :topic_name_assignments, :dependent => :destroy
  has_many :entries, :through => :topic_name_assignments
  
  has_many :topics_topic_names, :dependent => :destroy
  has_many :topics, :through => :topics_topic_names
  
  default_scope :order => "topic_names.name"
  named_scope :unprocessed, :conditions => {:void => false, :topics_count => 0}, :order => "topic_names.name"
  
  validate :does_not_have_topics_if_void

  before_save :update_topics_count

  def processed?
    void? || (topics_count > 0)
  end
  
  def unprocessed?
    !processed?
  end
  
  def topic_ids=(ids)
    ids = ids.reject(&:blank?).map(&:to_i)
    ids_to_remove = topic_ids - ids
    ids_to_add = ids - topic_ids
    
    ids_to_remove.each do |topic_id|
      topics_topic_names.to_a.find{|t| t.topic_id == topic_id}.destroy
    end
    
    ids_to_add.each do |topic_id|
      self.topics_topic_names.create(:topic_id => topic_id)
    end
    
    ids
  end
  
  private
    
    def does_not_have_topics_if_void
      errors.add_to_base("all topics must be removed if marking as void") if (void? && topic_ids.size > 0)
    end
    
    def update_topics_count
      self.topics_count = topic_ids.size
    end
end
