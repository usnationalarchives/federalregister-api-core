class Section < ApplicationModel
  has_many :section_assignments

  has_many :section_highlights

  has_many :agencies_sections
  has_many :agencies, :through => :agencies_sections, :order => "agencies.name"
  has_many :canned_searches

  validates_uniqueness_of :title
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /\A[a-z0-9-]+\z/

  validate :cfr_format_is_valid

  def entries
    Entry.scoped(:conditions => {:section_assignments => {:section_id => id}}, :joins => :section_assignments)
  end

  def to_param
    slug
  end

  def highlighted_entries(publication_date=Issue.current.publication_date)
    Entry.scoped(
      :conditions => {
        :section_highlights => {
          :publication_date => publication_date,
          :section_id => id
        }
      },
      :joins => :section_highlights,
      :order => "section_highlights.position"
    )
  end

  def cfr_citation_ranges
    @ranges ||= CfrCitationRange::Parser.new(relevant_cfr_sections).ranges
  end

  def should_include_entry?(entry)
    return true if (agencies & entry.agencies.excluding_parents).size > 0
    cfr_citation_ranges.any? do |range|
      entry.entry_cfr_affected_parts.any? do |ecap|
        range.includes?(ecap.title, ecap.part)
      end
    end
  end

  def popular_topics(n = 10, since = 1.week.ago)
    entry_scope = self.entries.popular
    sub_query = Entry.construct_finder_sql(entry_scope.current_scoped_methods[:find])

    Topic.scoped(
      :select => "topics.id, topics.name, topics.slug, sum(popular_entries.num_views) AS total_views",
      :joins => "INNER JOIN topic_assignments ON topic_assignments.topic_id = topics.id JOIN (#{sub_query}) AS popular_entries ON popular_entries.id = topic_assignments.entry_id",
      :group => "topics.id",
      :having => "total_views > 0",
      :order => "total_views DESC"
    )
  end

  private

  def cfr_format_is_valid
    begin
      cfr_citation_ranges
    rescue CfrCitationRange::Parser::InvalidFormat => e
      errors.add(:relevant_cfr_sections, e.message)
    end
  end
end
