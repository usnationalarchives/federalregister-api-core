=begin Schema Information

 Table name: agency_assignments

  id         :integer(4)      not null, primary key
  agency_id  :integer(4)
  entry_id   :integer(4)
  created_at :datetime
  updated_at :datetime

=end Schema Information

class AgencyAssignment < ActiveRecord::Base
  belongs_to :agency
  belongs_to :entry
end
