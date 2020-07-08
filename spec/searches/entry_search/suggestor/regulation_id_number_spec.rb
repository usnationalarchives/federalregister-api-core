require "spec_helper"

describe 'EntrySearch::Suggestor::RegulationIdNumber' do
  def suggestor(term, options = {})
    conditions = options.merge(:term => term)
    EntrySearch::Suggestor::RegulationIdNumber.new(EsEntrySearch.new(:conditions => conditions))
  end

  describe "valid RIN in search term" do
    before(:each) do
      Factory(:regulatory_plan, :regulation_id_number => "0648-AS38")
    end
    it "should remove the RIN from the search term" do
      suggestion = suggestor("0648-AS38 groundfish").suggestion
      suggestion.term.should == "groundfish"
    end

    it "adds the RIN condition" do
      Factory(:regulatory_plan, :regulation_id_number => "0648-AS38")
      suggestion = suggestor("0648-AS38 groundfish").suggestion
      suggestion.regulation_id_number.should == "0648-AS38"
    end
  end

  describe "invalid RIN in search term" do
    it "should not provide a suggestion" do
      suggestion = suggestor("0648-XXXX groundfish").suggestion
      suggestion.should be_nil
    end
  end

  describe "no RIN in search term" do
    it "should not provide a suggestion" do
      suggestion = suggestor("groundfish").suggestion
      suggestion.should be_nil
    end
  end
end