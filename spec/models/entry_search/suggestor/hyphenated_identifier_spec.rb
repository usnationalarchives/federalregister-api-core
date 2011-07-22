require "spec_helper"

describe 'EntrySearch::Suggestor::HyphenatedIdentifier' do
  def suggestor(term, options = {})
    conditions = options.merge(:term => term)
    EntrySearch::Suggestor::HyphenatedIdentifier.new(EntrySearch.new(:conditions => conditions))
  end
  
  describe "unquoted identifiers" do
    [
      ['abc 1a-2b 123', 'abc "1a-2b" 123'],
      ['asf asf1-fsa',  'asf "asf1-fsa"'],
      ['asf asf-fsa1',  'asf "asf-fsa1"'],
      ['123-456', '"123-456"']
    ].each do |term, quoted_term|
      it "should quote the identifier in #{term}" do
        suggestor(term).suggestion.term.should == quoted_term
      end
    end
  end
  
  describe "quoted identifiers" do
    [
      'abc "1a-2b" 123',
      'asf "asf1-fsa"',
      'asf "asf-fsa1"',
      'asf "asf-fsa1 hey there"'
    ].each do |term|
      it "shouldn't match #{term}" do
        suggestor(term).suggestion.should be_nil
      end
    end
  end
  
  describe "non-identifiers" do
    [
      'abc 123 def',
      'abc foo-bar',
      '-123a',
      'a123-'
    ].each do |term| 
      it "shouldn't match #{term}" do
        suggestor(term).suggestion.should be_nil
      end
    end
  end
end