class Section < ActiveYaml::Base
  set_root_path "#{Rails.root}/data"
  field :name
  field :slug
  
  def entries
    Entry.scoped(:conditions => {:section_assignments => {:section_id => id}}, :joins => :section_assignments)
  end
end