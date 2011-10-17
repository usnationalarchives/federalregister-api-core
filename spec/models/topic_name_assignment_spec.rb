# == Schema Information
#
# Table name: topic_name_assignments
#
#  id            :integer(4)      not null, primary key
#  entry_id      :integer(4)
#  topic_name_id :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe TopicNameAssignment do
  describe 'create' do
    it "creates topic_assignments for each topics_topic_name" do
      entry = Factory(:entry)
      entry.topics.size.should == 0
      topic_name = Factory(:topic_name, :topics => [Factory(:topic), Factory(:topic)])
      TopicNameAssignment.create(:entry => entry, :topic_name => topic_name)
      entry.topics.size.should == 2
    end
  end
  
  describe 'destroy' do
    it "should destroy all associated topic_assignments" do
      entry = Factory(:entry)
      topic_name = Factory(:topic_name, :topics => [Factory(:topic), Factory(:topic)])
      topic_name_assignment = TopicNameAssignment.create(:entry => entry, :topic_name => topic_name)
      entry.topics.size.should == 2
      topic_name_assignment.destroy
      entry.topics.size.should == 0
    end
  end
end
