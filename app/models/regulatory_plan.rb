class RegulatoryPlan < ActiveRecord::Base
  SIGNIFICANT_PRIORITY_CATEGORIES = ['Economically Significant', 'Other Significant']
  
  file_attribute(:full_xml)  {"#{RAILS_ROOT}/data/regulatory_plans/#{issue}/#{regulation_id_number}.xml"}
  
  has_many :events, :class_name => "RegulatoryPlanEvent"
  has_many :events,
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number
  has_many :entries,
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number
  
  def self.current_issue
    RegulatoryPlan.first(:select => :issue, :order => "issue DESC").try(:issue)
  end
end