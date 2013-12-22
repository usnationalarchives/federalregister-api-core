require 'spec_helper'

describe SpellChecker do
  subject { SpellChecker.new }
  describe "#check" do
    it "leaves correctly spelled words unchanged" do
      correct_with_suggestions("the cow jumped over the moon").should == "the cow jumped over the moon"
    end

    it "leaves capitalization in place" do
      correct_with_suggestions("The cow jumped over the Moon").should == "The cow jumped over the Moon"
    end

    it "ignores words in all caps" do
      correct_with_suggestions("the cow jumped over TEH moon").should == "the cow jumped over TEH moon"
    end
    it "leaves punctuation in place" do
      correct_with_suggestions("the cow, jumping over the moon.").should == "the cow, jumping over the moon."
    end

    it "combines words with apostropes for purposes of suggestions" do
      correct_with_suggestions("that cow an't jumping over the moon").should == "that cow (an't=ant|ain't|can't|shan't|aren't|Anita|mayn't) jumping over the moon"
    end

    it "leaves single quotes alone otherwise" do
      correct_with_suggestions("The cow said 'noo'").should == "The cow said '(noo=new|nu|boo|moo|no|noon|nook|nos|non|nor|not|too|loo|coo|nod)'"
    end

    it "ignores words with numbers" do
      correct_with_suggestions("42 c0ws jumped over the moon").should == "42 c0ws jumped over the moon"
    end
  end

  def correct_with_suggestions(string)
    subject.correct(string) do |word, suggestions|
      "(#{word}=#{suggestions.join('|')})"
    end
  end
end
