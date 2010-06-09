=begin Schema Information

 Table name: topics

  id                     :integer(4)      not null, primary key
  name                   :string(255)
  created_at             :datetime
  updated_at             :datetime
  slug                   :string(255)
  entries_count          :integer(4)      default(0)
  related_topics_cache   :text
  related_agencies_cache :text

=end Schema Information

class Topic < ApplicationModel
  has_many :topic_assignments
  has_many :entries, :through => :topic_assignments
  serializable_column :related_topics_cache, :related_agencies_cache

  def to_param
    slug
  end
  
  before_save :generate_slug
  
  private
  
  def generate_slug
    slug = self.name.downcase
    slug.gsub!(/[^a-z ]/,' ')
    slug.gsub!(/\b(?:and|by|the|a|an|of|in|on|to|for|s|etc|promotion)\b/, ' ')
    
    slug.gsub!(/ {2,}/, ' ')
    
    self.slug = slug.strip.gsub(/ /, '-')
  end
end

