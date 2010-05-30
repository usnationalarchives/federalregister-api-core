=begin Schema Information

 Table name: agencies_sections

  id         :integer(4)      not null, primary key
  section_id :integer(4)
  agency_id  :integer(4)
  created_at :datetime
  updated_at :datetime
  creator_id :integer(4)
  updater_id :integer(4)

=end Schema Information

class AgenciesSection < ApplicationModel
  belongs_to :agency
  belongs_to :section
end
