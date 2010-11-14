require "spec_helper"

describe EntrySearch do
  describe 'regulation_id_number' do
    it "populates sphinx `conditions` and properly quotes" do
      search = EntrySearch.new()
      search.regulation_id_number = "ABCD-1234"
      search.sphinx_conditions.should == {:regulation_id_number => '"ABCD-1234"'}
    end
  end
  
  describe 'matching_entry_citation' do
    before(:each) do
      Issue.stubs(:current).returns(Issue.new(:publication_date => Date.today))
    end
    
    it "finds no match when no term" do
      EntrySearch.new().matching_entry_citation.should be_nil
    end
    
    it "finds no match for terms that aren't FR citations" do
      EntrySearch.new(:conditions => {:term => "ABCD"}).matching_entry_citation.should be_nil
      EntrySearch.new(:conditions => {:term => "10 CFR 120"}).matching_entry_citation.should be_nil
    end
    
    it "finds no match for terms that contain more than an FR citation" do
      EntrySearch.new(:conditions => {:term => "before 71 FR 12345"}).matching_entry_citation.should be_nil
      EntrySearch.new(:conditions => {:term => "71 FR 12345 after"}).matching_entry_citation.should be_nil
      EntrySearch.new(:conditions => {:term => "before 71 FR 12345 after"}).matching_entry_citation.should be_nil
    end
    
    it "finds a match for valid FR citations" do
      citation_attributes = Citation.new(:citation_type => "FR", :part_1 => 71, :part_2 => 12345).attributes
      EntrySearch.new(:conditions => {:term => "71 FR 12345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71FR12345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => " 71 FR 12345 "}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71 F.R. 12345"}).matching_entry_citation.attributes.should == citation_attributes
    end
  end
end