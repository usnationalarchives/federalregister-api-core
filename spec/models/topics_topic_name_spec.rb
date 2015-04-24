require 'spec_helper'

describe TopicsTopicName do
  describe 'create' do
    it "create topic_assignments for each of topic_name's topic_name_assignments" do
      topic_name = Factory(:topic_name)
      entry = Factory(:entry, :topic_names => [topic_name])
      topic = Factory(:topic)
      TopicsTopicName.create(:topic_name => topic_name, :topic => topic)
      entry.topics.should == [topic]
    end
  end
  
  describe 'destroy' do
    it "should destroy all associated topic_assignments" do
      topic_name = Factory.create(:topic_name)
      entry = Factory(:entry, :topic_names => [topic_name])
      topics_topic_name = TopicsTopicName.create(:topic_name => topic_name, :topic => Factory(:topic))
      TopicAssignment.count.should == 1
      topics_topic_name.destroy
      TopicAssignment.count.should == 0
    end
  end
end
