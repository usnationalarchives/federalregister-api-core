class Section < ActiveYaml::Base
  set_root_path "#{Rails.root}/data"
  field :name
  field :slug
  
  def to_param
    slug
  end
  
  def highlighted_entries(publication_date)
    Entry.scoped(:conditions => {:section_highlights => {:publication_date => publication_date, :section_id => id}}, :joins => :section_highlights, :order => "section_highlights.position")
  end
  
  def entries
    Entry.scoped(:conditions => {:section_assignments => {:section_id => id}}, :joins => :section_assignments)
  end
end