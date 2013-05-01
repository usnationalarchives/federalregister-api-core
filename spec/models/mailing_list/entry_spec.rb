require 'spec_helper'

describe MailingList::Entry do
  describe 'search' do
    it "is a EntrySearch object" do
      Factory(:mailing_list_entry).search.should be_a(EntrySearch)
    end
  end
  
  describe 'title' do
    it "is based on the search's title" do
      search = EntrySearch.new(:conditions => {:term => "Bar"})
      list = Factory.build(:mailing_list_entry, :search => search)
      list.save!
      list.title.should == search.summary
    end
  end
  
  describe 'active' do
    it "returns all mailing_lists with more than one active subscription" do
      list_1 = Factory(:mailing_list_entry, :active_subscriptions_count => 0)
      list_2 = Factory(:mailing_list_entry, :active_subscriptions_count => 1)
      
      MailingList::Entry.active.should == [list_2]
    end
  end
  
  describe 'search_conditions' do
    it "are stored as JSON" do
      list = Factory(:mailing_list_entry, :search => EntrySearch.new(:conditions => {:term => 'OH HAI'}))
      list['search_conditions'].should == '{"term":"OH HAI"}'
    end
    
    it "are retrievable by EntrySearch" do
      list = Factory(:mailing_list_entry, :search => EntrySearch.new(:conditions => {:term => 'OH HAI'}))
      list.reload
      
      list.search.term.should == 'OH HAI'
    end
    
    it "are searchable" do
      list = Factory(:mailing_list_entry, :search => EntrySearch.new(:conditions => {:term => 'OH HAI'}))
      MailingList::Entry.find_by_search(EntrySearch.new(:conditions => {:term => 'OH HAI'})).should == list
      MailingList::Entry.find_by_search(EntrySearch.new(:conditions => {:term => 'LATERZ'})).should be_nil
    end
  end
end
