class IssuePart < ApplicationModel
  belongs_to :issue
  has_many :entries
end
