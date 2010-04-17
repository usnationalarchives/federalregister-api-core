class SectionAssignment < ActiveRecord::Base
  belongs_to :entry
  belongs_to :section
end