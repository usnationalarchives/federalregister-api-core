require 'test_helper'

class AgencyAssignmentTest < ActiveSupport::TestCase
  should_belong_to :entry
  should_belong_to :agency
  
  should_have_index :entry_id, :agency_id
end