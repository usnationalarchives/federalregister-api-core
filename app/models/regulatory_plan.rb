=begin Schema Information

 Table name: regulatory_plans

  id                   :integer(4)      not null, primary key
  regulation_id_number :string(255)
  issue                :string(255)
  title                :text
  abstract             :text
  priority_category    :string(255)

=end Schema Information

class RegulatoryPlan < ApplicationModel
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
  
  def significant?
    priority_category.include?(RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES)
  end
end
