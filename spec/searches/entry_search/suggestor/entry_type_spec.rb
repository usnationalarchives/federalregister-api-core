require "spec_helper"

describe 'EntrySearch::Suggestor::EntryType' do
  def suggestor(term, options = {})
    conditions = options.merge(:term => term)
    EntrySearch::Suggestor::EntryType.new(EntrySearch.new(:conditions => conditions))
  end

  describe "presidential documents" do
    ["president goats", "presidential goats", "goats president", "goats:president"].each do |term|
      it "should add set the type to PRESDOC and remove the term when given '#{term}'" do
        suggestion = suggestor(term).suggestion
        suggestion.term.should == 'goats'
        suggestion.type.should == 'PRESDOCU'
      end
    end

    ["fooeo goats"].each do |term|
      it "shouldn't have a suggestion match #{term}" do
        suggestion = suggestor(term).suggestion.should be_nil
      end
    end
    it "shouldn't match inside of a phrase" do
      suggestor('"Cross-Media Electronic Reporting Rule"').suggestion.should be_nil
    end

    it "shouldn't match exact words" do
      suggestor('=rule').suggestion.should be_nil
    end

    it "shouldn't match negated words" do
      suggestor('-rule').suggestion.should be_nil
    end

    it "shouldn't match exact negated words" do
      suggestor('-=rule').suggestion.should be_nil
    end
  end
end
