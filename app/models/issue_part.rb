class IssuePart < ApplicationModel
  belongs_to :issue
  has_many :entries

  validates :issue_id, uniqueness: { scope: [:start_page, :end_page, :title] }
end
