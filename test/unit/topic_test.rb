require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  should_have_many :topic_assignments
  should_have_many :entries, :through => :topic_assignments
end