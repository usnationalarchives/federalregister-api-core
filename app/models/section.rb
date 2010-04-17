class Section < ActiveYaml::Base
  set_root_path "#{Rails.root}/data"
  has_many :section_assignments
  has_many :entries, :through => :section_assignments
end