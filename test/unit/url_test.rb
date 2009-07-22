require 'test_helper'

class UrlTest < ActiveSupport::TestCase
  should_have_many :url_references
  should_have_many :entries, :through => :url_references
end