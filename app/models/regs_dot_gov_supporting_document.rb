class RegsDotGovSupportingDocument < ApplicationModel
  serialize :metadata, Hash
  belongs_to :regs_dot_gov_docket, foreign_key: :docket_id
end
