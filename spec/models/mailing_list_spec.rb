=begin Schema Information

 Table name: mailing_lists

  id                         :integer(4)      not null, primary key
  search_conditions          :text
  title                      :string(255)
  active_subscriptions_count :integer(4)      default(0)
  created_at                 :datetime
  updated_at                 :datetime

=end Schema Information

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
    it "are stored as JSON" do
      list = Factory(:mailing_list, :search => EntrySearch.new(:conditions => {:term => 'OH HAI'}))
      list['search_conditions'].should == '{"term":"OH HAI"}'
    end
    
    it "are retrievable by EntrySearch" do
      list = Factory(:mailing_list, :search => EntrySearch.new(:conditions => {:term => 'OH HAI'}))
      list.reload
      
      list.search.term.should == 'OH HAI'
    end
    
    it "are searchable" do
      list = Factory(:mailing_list, :search => EntrySearch.new(:conditions => {:term => 'OH HAI'}))
      MailingList.find_by_search(EntrySearch.new(:conditions => {:term => 'OH HAI'})).should == list
      MailingList.find_by_search(EntrySearch.new(:conditions => {:term => 'LATERZ'})).should be_nil
    end
  end
end
