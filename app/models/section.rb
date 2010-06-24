=begin Schema Information

 Table name: sections

  id                    :integer(4)      not null, primary key
  title                 :string(255)
  slug                  :string(255)
  position              :integer(4)
  description           :text
  relevant_cfr_sections :text
  created_at            :datetime
  updated_at            :datetime
  creator_id            :integer(4)
  updater_id            :integer(4)

=end Schema Information

class Section < ApplicationModel
  has_many :agencies_sections
  has_many :agencies, :through => :agencies_sections, :order => "agencies.name"
  
  validates_uniqueness_of :title
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /^[a-z0-9-]+$/
  
  validate :cfr_format_is_valid
  
  def to_param
    slug
  end
  
  def highlighted_entries(publication_date = Entry.latest_publication_date)
    Entry.scoped(:conditions => {:section_highlights => {:publication_date => publication_date, :section_id => id}}, :joins => :section_highlights, :order => "section_highlights.position")
  end
  
  def entries
    Entry.scoped(:conditions => {:section_assignments => {:section_id => id}}, :joins => :section_assignments)
  end
  
  def cfr_citation_ranges
    @ranges ||= CfrCitationRange::Parser.new(relevant_cfr_sections).ranges
  end
  
  def should_include_entry?(entry)
    cfr_citation_ranges.any?{|range| range.includes?(entry.cfr_title, entry.cfr_part)} || (agencies & entry.agencies_excluding_parents).size > 0
  end
  
  def popular_topics(n = 10, since = 1.month.ago)
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
