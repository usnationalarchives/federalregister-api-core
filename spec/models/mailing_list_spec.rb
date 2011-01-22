require 'spec_helper'

describe MailingList do
  it { should validate_presence_of(:parameters) }
  it { should validate_presence_of(:title) }
  
  describe 'search' do
    it "is a EntrySearch object" do
      Factory(:mailing_list).search.should be_a(EntrySearch)
    end
  end
  
  describe 'title' do
    it "is based on the search's title" do
      list = Factory.build(:mailing_list)
      search = list.search
      
      search.expects(:title).and_returns("a generated title")
      list.save!
      list.title.should == "a generated title"
    end
  end
  
  describe 'active' do
    it "returns all mailing_lists with more than one active subscription" do
      list_1 = Factory(:mailing_list, :active_subscriptions_count => 0)
      list_2 = Factory(:mailing_list, :active_subscriptions_count => 1)
      
      MailingList.active.should == [list_2]
    end
  end
end
