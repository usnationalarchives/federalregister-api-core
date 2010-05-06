=begin Schema Information

 Table name: regulatory_plan_events

  id                 :integer(4)      not null, primary key
  regulatory_plan_id :integer(4)
  date               :string(255)
  action             :string(255)
  fr_citation        :string(255)

=end Schema Information

class RegulatoryPlanEvent < ApplicationModel
  belongs_to :regulatory_plan
end
