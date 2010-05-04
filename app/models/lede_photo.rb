class LedePhoto < ApplicationModel
  has_many :entries
  has_attached_file :photo
end