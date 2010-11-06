require "spec_helper"

describe EntrySearch do
  before(:each) do
    @search_class = Class.new(ApplicationSearch)
  end
  
  describe 'define_filter' do
    before(:each) do
      @search_class.define_filter :topic_id
    end
    
    it "creates an instance setter method" do
      @search_class.new.should respond_to :topic_id=
    end
    
    it "creates an instance getter method" do
      @search_class.new.should respond_to :topic_id
    end
    
    it "adds a filter when used" do
      search = @search_class.new
      search.topic_id = 1
      search.filters.size.should == 1
    end
  end
end