require "spec_helper"

describe 'EntrySearch::Suggestor::Date' do
  def suggestor(term, options = {})
    conditions = options.merge(:term => term)
    EntrySearch::Suggestor::Date.new(EntrySearch.new(:conditions => conditions))
  end
  
  describe "valid date in search term" do
    it "should remove the date from the search term" do
      suggestion = suggestor("3/25/2011 interpretation guidance").suggestion
      suggestion.term.should == "interpretation guidance"
    end
    
    it "should add the date as a publication date filter" do
      suggestion = suggestor("3/25/2011 interpretation guidance").suggestion
      suggestion.publication_date.is.should == "03/25/2011"
    end
    
    it "should assume that date is in the proper century" do
      suggestion = suggestor("3/25/11 interpretation guidance").suggestion
      suggestion.publication_date.is.should == "03/25/2011"

      suggestion = suggestor("3/25/90 interpretation guidance").suggestion
      suggestion.publication_date.is.should == "03/25/1990"
    end
  end
  
  describe "invalid date in search term" do
    it "should return no suggestions" do
      suggestion = suggestor("3/42/11 interpretation guidance").suggestion
      suggestion.should be_nil
    end
  end
  
  describe "no date in search term" do
    it "should return no suggestions" do
      suggestion = suggestor("interpretation guidance").suggestion
      suggestion.should be_nil
    end
  end
end