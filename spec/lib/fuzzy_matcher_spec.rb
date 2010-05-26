require 'spec_helper'

describe FuzzyMatcher do
  describe "#normalize_term" do
    before(:each) { @assigner = FuzzyMatcher.new}
    it "downcases" do
      @assigner.normalize_term("AGRICULTURE").should == 'agriculture'
    end
    
    it "cleans up whitespace" do
      @assigner.normalize_term(" foo ").should == 'foo'
    end
    
    it "removes stopwords" do
      @assigner.normalize_term("the cow jumped over the moon").should == 'cow jumped over moon'
    end
  end
  
  describe "#suggest" do
    before(:each) { @assigner = FuzzyMatcher.new(:candidates => ["cat", "kitten", "kittens", "dog", "the puppy"])}
    
    it "suggests nothing if no close match" do
      @assigner.suggest("dinosaur").should == nil
    end
    
    it "finds the closest match" do
      @assigner.suggest("kitteh").should == "kitten"
    end
    
    it "normalize input terms" do
      @assigner.suggest("   a       kittee ").should == "kitten"
    end
    
    it "normalizes candidates" do
      @assigner.suggest("puppy").should == "the puppy"
    end
  end
end
