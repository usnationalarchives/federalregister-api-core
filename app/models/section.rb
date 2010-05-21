class Section < ApplicationModel
  validates_uniqueness_of :title
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /^[a-z-]+$/
  
  validate :cfr_format_is_valid
  
  def to_param
    slug
  end
  
  def highlighted_entries(publication_date)
    Entry.scoped(:conditions => {:section_highlights => {:publication_date => publication_date, :section_id => id}}, :joins => :section_highlights, :order => "section_highlights.position")
  end
  
  def entries
    Entry.scoped(:conditions => {:section_assignments => {:section_id => id}}, :joins => :section_assignments)
  end
  
  def cfr_citation_ranges
    @ranges ||= CfrCitationRange::Parser.new(relevant_cfr_sections).ranges
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