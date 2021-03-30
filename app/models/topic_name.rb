class TopicName < ApplicationModel
  has_many :topic_name_assignments, :dependent => :destroy
  has_many :entries, :through => :topic_name_assignments

  has_many :topics_topic_names, :dependent => :destroy
  has_many :topics, :through => :topics_topic_names

  default_scope { order("topic_names.name") }
  scope :unprocessed, -> { where(:void => false, :topics_count => 0).order("topic_names.name") }

  validate :does_not_have_topics_if_void

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

    self.topics_count = ids.size

    ids
  end

  private

    def does_not_have_topics_if_void
      errors.add(:base, "All topics must be removed if marking as void") if (void? && topics_count && topics_count > 0)
    end
end
