class EntryRegulationIdNumber < ApplicationModel
  belongs_to :entry
  has_many :regulatory_plans,
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number
  has_one  :current_regulatory_plan,
           -> { where(:regulatory_plans => {:current => true} ) },
           :class_name => "RegulatoryPlan",
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number
end
