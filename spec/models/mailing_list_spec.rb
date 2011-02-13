require 'spec_helper'

describe MailingList do
  describe 'search' do
    it "is a EntrySearch object" do
      Factory(:mailing_list).search.should be_a(EntrySearch)
    end
  end
  
  describe 'title' do
    it "is based on the search's title" do
      search = EntrySearch.new(:conditions => {:term => "Bar"})
      list = Factory.build(:mailing_list, :search => search)
      list.save!
      list.title.should == search.summary
    end
  end
  
  describe 'active' do
    it "returns all mailing_lists with more than one active subscription" do
      list_1 = Factory(:mailing_list, :active_subscriptions_count => 0)
      list_2 = Factory(:mailing_list, :active_subscriptions_count => 1)
      
      MailingList.active.should == [list_2]
    end
  end
  
  describe 'search_conditions' do
    it "stores the values as JSON" do
      list = Factory(:mailing_list, :search => EntrySearch.new(:conditions => {:term => 'OH HAI'}))
      list['search_conditions'].should == '{"term":"OH HAI"}'
    end
  end
end
