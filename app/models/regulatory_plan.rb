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
  extend ActiveSupport::Memoizable
  
  SIGNIFICANT_PRIORITY_CATEGORIES = ['Economically Significant', 'Other Significant']
  
  file_attribute(:full_xml)  {"#{RAILS_ROOT}/data/regulatory_plans/#{issue}/#{regulation_id_number}.xml"}
  
  has_many :events,
           :class_name => "RegulatoryPlanEvent"
  has_many :entries,
           :primary_key => :regulation_id_number,
           :foreign_key => :regulation_id_number
  
  def self.current_issue
    RegulatoryPlan.first(:select => :issue, :order => "issue DESC").try(:issue)
  end
  
  def significant?
    RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES.include?(priority_category)
  end
  
  def slug
    self.title.downcase.gsub(/&/, 'and').gsub(/[^a-z0-9]+/, '-').slice(0,100)
  end
  
  def source_url(format)
    format = format.to_sym
    
    case format
    when :html
      "http://www.reginfo.gov/public/do/eAgendaViewRule?pubId=#{issue}&RIN=#{regulation_id_number}"
    when :xml
      "http://www.reginfo.gov/public/do/eAgendaViewRule?pubId=#{issue}&RIN=#{regulation_id_number}&operation=OPERATION_EXPORT_XML"
    end
  end
  
  def statement_of_need
    simple_node_value('STMT_OF_NEED')
  end
  
  def legal_basis
    simple_node_value('LEGAL_BASIS')
  end
  
  def alternatives
    simple_node_value('ALTERNATIVES')
  end
  
  def costs_and_benefits
    simple_node_value('COSTS_AND_BENEFITS')
  end
  
  def risks
    simple_node_value('RISKS')
  end
  
  private
  
  def root_node
    @root_node ||= Nokogiri::XML(full_xml).root
  end
  
  def simple_node_value(css_selector)
    if root_node
      root_node.css(css_selector).first.try(:content)
    end
  end
  memoize :simple_node_value
  
end
