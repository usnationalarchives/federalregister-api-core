class RegsDotGovDocument < ApplicationModel
  belongs_to :entry,
    foreign_key: :federal_register_document_number,
    primary_key: :document_number

  belongs_to :regs_dot_gov_docket,
    foreign_key: :docket_id

  default_scope { where(deleted_at: nil) }
  scope :active, -> { where(deleted_at: nil) }

  validates_uniqueness_of :regulations_dot_gov_document_id, scope: :deleted_at

  def comment_url
    "https://www.regulations.gov/commenton/#{regulations_dot_gov_document_id}"
  end
end
