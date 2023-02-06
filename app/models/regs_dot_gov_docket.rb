class RegsDotGovDocket < ApplicationModel
  serialize :metadata, Hash
  has_many :regs_dot_gov_supporting_documents, foreign_key: :docket_id

  def placeholder?
    id =~ /.*_FRDOC_0001$/
  end

  def regulatory_plan
    if regulation_id_number.present?
      @regulatory_plan ||= RegulatoryPlan.find_by_regulation_id_number(regulation_id_number)
    end
  end
end
