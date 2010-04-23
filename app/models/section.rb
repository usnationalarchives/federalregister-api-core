class Section < ActiveYaml::Base
  set_root_path "#{Rails.root}/data"
  field :name
  field :slug
end