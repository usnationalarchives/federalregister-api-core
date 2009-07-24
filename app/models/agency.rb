=begin Schema Information

 Table name: agencies

  id         :integer(4)      not null, primary key
  parent_id  :integer(4)
  name       :string(255)
  created_at :datetime
  updated_at :datetime

=end Schema Information

class Agency < ActiveRecord::Base
  has_many :agency_assignments
  has_many :entries, :through => :agency_assignments
end
