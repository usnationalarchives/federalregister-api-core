require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  should_have_many :agency_assignments
  should_have_many :agencies, :through => :agency_assignments
  
  should_have_many :url_references
  should_have_many :urls, :through => :url_references
end