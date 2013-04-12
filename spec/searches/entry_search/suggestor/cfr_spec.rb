require "spec_helper"

describe 'EntrySearch::Suggestor::Cfr' do
  def suggestor(term, options = {})
    conditions = options.merge(:term => term)
    EntrySearch::Suggestor::Cfr.new(EntrySearch.new(:conditions => conditions))
  end

  describe "valid CFR citation in search term" do
    [
      "10 CFR 12345",
      "10 C.F.R. 12345",
      "10 CFR part 12345",
      "10 C.F.R. pt 12345",
      "10 C.F.R. Pt. 12345",
      "10 C.F.R. pt. 12,345",
    ].each do |citation|
      it "should remove the citation from the search term" do
        suggestion = suggestor("#{citation} groundfish").suggestion
        suggestion.term.should == "groundfish"
      end

      it "should add the citation condition" do
        suggestion = suggestor("#{citation} groundfish").suggestion
        suggestion.cfr.should == EntrySearch::CFR.new("10","12345")
      end
    end
  end

  describe "no CFR in search term" do
    it "should not provide a suggestion" do
      suggestion = suggestor("groundfish").suggestion
      suggestion.should be_nil
    end
  end

end
