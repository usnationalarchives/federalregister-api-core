require 'test_helper'

class AgencyTest < ActiveSupport::TestCase
  should_have_many :entries
end