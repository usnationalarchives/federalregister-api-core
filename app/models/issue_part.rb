class IssuePart < ApplicationRecord
  belongs_to :issue
  has_many :entries
end
