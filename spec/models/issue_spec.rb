=begin Schema Information

 Table name: issues

  id               :integer(4)      not null, primary key
  publication_date :date
  completed_at     :datetime
  created_at       :datetime
  updated_at       :datetime

=end Schema Information

require 'spec_helper'

describe Issue do
  describe "complete?" do
    it "is not complete when no issue exists for a given date" do
      Issue.complete?(Time.current.to_date).should be false
    end
    
    it "is not complete when the issue does not have completed_at set" do
      Issue.create!(:publication_date => Time.current.to_date)
      Issue.complete?(Time.current.to_date).should be false
    end
    
    it "is complete when the issue does have completed_at set" do
      issue = Issue.create!(:publication_date => Time.current.to_date, :completed_at => Time.now)
      Issue.complete?(Time.current.to_date).should be true
    end
  end
  
  describe "complete?" do
    it "is false when completed_at is not set" do
      Issue.new(:completed_at => nil).complete?.should be false
    end
    
    it "is true when completed_at is set" do
      Issue.new(:completed_at => Time.now).complete?.should be true
    end
  end
  
  describe "complete!" do
    it "should set completed_at to now if completed_at is nil" do
      Timecop.freeze do
        issue = Issue.new(:completed_at => nil)
        issue.complete!
        issue.completed_at.should == Time.now
      end
    end
    
    it "should not modify completed_at if completed_at is set" do
      Timecop.freeze do
        issue = Issue.new(:completed_at => 1.hour.ago)
        issue.complete!
        issue.completed_at.should == 1.hour.ago
      end
    end
  end
end
