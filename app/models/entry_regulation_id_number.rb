class EntryRegulationIdNumber < ApplicationModel
  belongs_to :entry
  has_many :regulatory_plans,
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number
end