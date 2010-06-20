class Event < ApplicationModel
  belongs_to :entry
  belongs_to :place
  
  validates_presence_of :entry, :place, :date, :title
end