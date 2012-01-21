class ActionName < ApplicationModel
  has_many :entries

  validates_presence_of :name
  validates_uniqueness_of :name
end
