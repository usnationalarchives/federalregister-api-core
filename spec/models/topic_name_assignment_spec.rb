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
