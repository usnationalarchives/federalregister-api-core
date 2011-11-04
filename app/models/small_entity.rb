# == Schema Information
#
# Table name: small_entities
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

class SmallEntity < ApplicationModel
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :regulatory_plans
end
