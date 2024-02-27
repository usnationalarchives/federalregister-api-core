class Topic < ApplicationModel
  has_many :topic_assignments, :dependent => :destroy
  has_many :entries, :through => :topic_assignments
  serializable_column :related_topics_cache, :related_agencies_cache

  ROUTINE_TOPIC_IDS = [8,   #Administrative Practice and Proceedure
                       34,  #Aircraft
                       932, #Reporting and Recordkeeping Requirements
                       947  #Safety
                      ]

  def to_param
    slug
  end

  before_save :generate_slug

  def self.top_by_article_count(count)
    scoped(:order => "topics.entries_count DESC",
        :conditions => "topics.entries_count > 0",
        :limit => count)
  end

  def self.without_routine
    scoped(:conditions => ["topics.id NOT IN (?)", ROUTINE_TOPIC_IDS])
  end

  def self.in_last_days(count)
    scoped(:joins => :entries,
           :group => "topics.name",
           :conditions => ["entries.publication_date > ?", Issue.current.publication_date - count.days])
  end

  # consider using sphinx instead...
  def self.named_approximately(name)
    return [] if name.blank?
    words = name.downcase.split(/[^a-z]+/) - %w(a and & in for of on s the)

    if words.empty?
      scoped(:conditions => {:id => nil}) # null scope
    else
      condition_sql = "(" + words.map{"topics.name REGEXP ?"}.join(" AND ") + ")"
      # '[[:<:]]' is MySQL regex for 'beginning of word'
      bind_params = words.map{|word|"\\b#{Regexp.escape(word)}"}
      condition_sql = condition_sql + " && topics.entries_count > 0"

      topics = scoped(
        :conditions => [
          condition_sql, *bind_params
        ],
        :order => "topics.name"
      )
    end
  end

  private

  def generate_slug
    slug = self.name.downcase
    slug.gsub!(/[^a-z ]/,' ')
    slug.gsub!(/\b(?:and|by|the|a|an|of|in|on|to|for|s|etc|promotion)\b/, ' ')

    slug.gsub!(/ {2,}/, ' ')

    self.slug = slug.strip.gsub(/ /, '-')
  end
end

