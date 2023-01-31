class RegsDotGovDocket < ApplicationModel
  serialize :metadata, Hash
  has_many :regs_dot_gov_documents, -> { where(deleted_at: nil) }, foreign_key: :docket_id
  has_many :entries, through: :regs_dot_gov_documents
  has_many :regs_dot_gov_supporting_documents, foreign_key: :docket_id

  DEFAULT_DOCKET_REGEX = /_0001$/
  def placeholder?
    id.match? DEFAULT_DOCKET_REGEX
  end
  alias_method :default_docket?, :placeholder?

  def regulatory_plan
    if regulation_id_number.present?
      @regulatory_plan ||= RegulatoryPlan.find_by_regulation_id_number(regulation_id_number)
    end
  end

end
