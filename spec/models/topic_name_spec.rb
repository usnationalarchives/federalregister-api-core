require 'spec_helper'

describe TopicName do
  describe 'destroy' do
    it "deletes all associated topic_name_assignments" do
      topic_name = Factory(:topic_name, :topics => [Factory(:topic)])
      entry = Factory(:entry, :topic_names => [topic_name])
      TopicNameAssignment.count == 1
      topic_name.destroy
      TopicNameAssignment.count == 0
    end

    it "deletes all associated topic_assignments" do
      topic_name = Factory(:topic_name, :topics => [Factory(:topic)])
      entry = Factory(:entry, :topic_names => [topic_name])
      TopicAssignment.count == 1
      topic_name.destroy
      TopicAssignment.count == 0
    end
  end

  describe 'update' do
    it "modifies topic_assignments when topic_ids changes" do
      topic_name = Factory(:topic_name)
      entry = Factory(:entry, :topic_names => [topic_name])

      topic_1 = Factory(:topic)
      topic_name.update!(:topic_ids => [topic_1.id])
      topic_name.reload
      entry.reload
      entry.topics.should == [topic_1]

      topic_2 = Factory(:topic)
      topic_name.update(:topic_ids => [topic_2.id])
      topic_name.reload
      entry.reload
      entry.topics.should == [topic_2]

      topic_name.update!(:topic_ids => [topic_1.id,topic_2.id])
      topic_name.reload
      entry.reload
      entry.topics.sort.should == [topic_1,topic_2]
    end
  end
end
