class SystemOfRecord < ApplicationModel
  has_many :system_of_record_assignments, dependent: :destroy
  has_many :entries, through: :system_of_record_assignments
end
