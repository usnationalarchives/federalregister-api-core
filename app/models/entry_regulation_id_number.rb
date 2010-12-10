=begin Schema Information

 Table name: entry_regulation_id_numbers

  id                   :integer(4)      not null, primary key
  entry_id             :integer(4)
  regulation_id_number :string(255)

=end Schema Information

class EntryRegulationIdNumber < ApplicationModel
  belongs_to :entry
  has_many :regulatory_plans,
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number
  has_one  :current_regulatory_plan,
           :class_name => "RegulatoryPlan",
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number,
           :conditions => {:regulatory_plans => {:issue => RegulatoryPlan.current_issue}}
end
