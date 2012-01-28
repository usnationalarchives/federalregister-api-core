# == Schema Information
#
# Table name: action_names
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ActionName < ApplicationModel
  has_many :entries

  validates_presence_of :name
  validates_uniqueness_of :name
end
