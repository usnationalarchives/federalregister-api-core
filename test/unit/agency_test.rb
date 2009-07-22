require 'test_helper'

class AgencyTest < ActiveSupport::TestCase
  should_have_many :agency_assignments
  should_have_many :entries, :through => :agency_assignments
end