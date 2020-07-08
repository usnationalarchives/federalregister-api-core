require "spec_helper"

describe 'EntrySearch::Suggestor::Base' do
  before(:each) do
    @class = Class.new(EntrySearch::Suggestor::Base) do
      def pattern
        /(FOO)/
      end

      def handle_match(txt)
        @conditions[:foo] = 1
      end
    end
  end
  describe "term" do
    it "removes the matching pattern from the term" do
      @class.new(EsEntrySearch.new(:conditions => {:term => "I love FOO because"})).suggestion.term.should == 'I love because'
    end

    it "removes the matching pattern and nearby 'and' from the term" do
      @class.new(EsEntrySearch.new(:conditions => {:term => "FOO and BAR"})).suggestion.term.should == 'BAR'
      @class.new(EsEntrySearch.new(:conditions => {:term => "BAR and FOO"})).suggestion.term.should == 'BAR'
      @class.new(EsEntrySearch.new(:conditions => {:term => "fish and FOO and BAR"})).suggestion.term.should == 'fish BAR'
    end
  end
end
