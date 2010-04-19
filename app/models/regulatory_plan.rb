class RegulatoryPlan < ActiveRecord::Base
  file_attribute(:full_xml)  {"#{RAILS_ROOT}/data/regulatory_plans/#{issue}/#{regulation_id_number}.xml"}
  
  has_many :events, :class_name => "RegulatoryPlanEvent"
end