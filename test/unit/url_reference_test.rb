require 'test_helper'

class UrlReferenceTest < ActiveSupport::TestCase
  should_belong_to :entry
  should_belong_to :url
  
  should_have_index :entry_id, :url_id
end