class EntryChange < ApplicationModel
  belongs_to :entry
  validates_uniqueness_of :entry_id
end
