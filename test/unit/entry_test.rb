require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  should_belong_to :agency
  
  should_have_many :url_references
  should_have_many :urls, :through => :url_references
end