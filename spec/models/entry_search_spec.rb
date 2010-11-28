require "spec_helper"

describe EntrySearch do
  describe 'agency_ids' do
    it "populates sphinx `with`" do
      search = EntrySearch.new()
      search.agency_ids = [1,2]
      search.with.should == {:agency_ids => [1,2]}
    end
  end
  
  describe 'significant' do
    it "populates sphinx `with`" do
      search = EntrySearch.new()
      search.significant = 1
      search.with.should == {:significant => 1}
    end
  end
  
  describe 'type' do
    it "populates sphinx `with`, CRC32 escaping" do
      search = EntrySearch.new
      search.type = ['RULE', 'PRORULE']
      search.with.should == {:type => ['RULE'.to_crc32, 'PRORULE'.to_crc32]}
    end
    
    it "collapses sunlight and notices"
  end
  
  describe 'cfr' do
    it "populates sphinx `with` using the custom citation format" do
      search = EntrySearch.new
      search.cfr = {:title => '10', :part => '101'}
      search.with.should == {:cfr_affected_parts => 1000101}
    end
  end
  
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
  
  describe 'publication_date' do
    [:is, :gte, :lte].each do |type|
      describe "`#{type}`" do
        describe 'error handling' do
          before(:each) do
            @date_string = "NOT A VALID DATE"
            @search = EntrySearch.new(:conditions => {:publication_date => {type => @date_string}})
          end
        
          it "adds an error when given a bad `#{type}` date" do
            @search.errors[:publication_date].should be_present
          end
      
          it "populates the value when given a bad `#{type}` date" do
            @search.publication_date.send(type).should == @date_string
          end
        end
      end
    end
  end
  
  describe 'entry_with_document_number' do
    before(:each) do
      Issue.stubs(:current).returns(Issue.new(:publication_date => Date.today))
    end
    
    it "finds no match when no term" do
      EntrySearch.new().entry_with_document_number.should be_nil
    end
    
    it "finds no match for terms that aren't FR citations" do
      EntrySearch.new(:conditions => {:term => "ABCD"}).entry_with_document_number.should be_nil
    end
    
    it "finds a match for valid FR document numbers" do
      entry = Entry.create!(:document_number => "2010-1")
      EntrySearch.new(:conditions => {:term => "2010-1"}).entry_with_document_number.should == entry
    end
  end
end