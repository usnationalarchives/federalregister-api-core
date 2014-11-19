require "spec_helper"

describe EntrySearch do
  use_vcr_cassette

  describe 'agency_ids' do
    it "populates sphinx `with`" do
      agencies = (1..2).map{ Factory.create(:agency) }
      search = EntrySearch.new()
      search.agency_ids = agencies.map(&:id)
      search.with.should == {:agency_ids => agencies.map(&:id)}
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
      search.sphinx_conditions.should == {:regulation_id_number => '"=ABCD =1234"'}
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
    
    it "finds a match for valid 'OFR-style' FR citations" do
      citation_attributes = Citation.new(:citation_type => "FR", :part_1 => 71, :part_2 => 12345).attributes
      EntrySearch.new(:conditions => {:term => "71 FR 12345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71FR12345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => " 71 FR 12345 "}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71 F.R. 12345"}).matching_entry_citation.attributes.should == citation_attributes
    end
    
    it "find a match for valid 'Harvard-style' FR citations" do
      citation_attributes = Citation.new(:citation_type => "FR", :part_1 => 71, :part_2 => 12345).attributes
      EntrySearch.new(:conditions => {:term => "71 Fed Reg 12345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71 Fed. Reg. 12345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71 Fed. Reg. 12,345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => " 71 fed reg 12345 "}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71 fedreg 12345"}).matching_entry_citation.attributes.should == citation_attributes
      EntrySearch.new(:conditions => {:term => "71fedreg12345"}).matching_entry_citation.attributes.should == citation_attributes
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
            @search.validation_errors[:publication_date].should be_present
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
  
  describe 'results_for_date' do
    it "retains the same filters/conditions, but forces a particular publication_date" do
      date = Date.parse("2010-10-10")
      search = EntrySearch.new(:conditions => {:term => "HOWDY", :significant => '1', :cfr =>{:title => '7', :part => '132'}})
      
      Entry.should_receive(:search).with do |term, options|
        term.should == 'HOWDY'
        options[:with][:significant].should == '1'
        options[:with][:publication_date].should == (date.to_time.utc.beginning_of_day.to_i .. date.to_time.utc.end_of_day.to_i)
        options[:per_page].should == 1000
      end
      search.results_for_date(date)
    end
  end
  
  describe "summary" do
    it "says 'All Documents' if no term or filters" do
      EntrySearch.new(:conditions => {}).summary.should == "All Documents"
    end
    
    it "includes the term" do
      EntrySearch.new(:conditions => {:term => "OH HAI"}).summary.should == "Documents matching 'OH HAI'"
    end
    
    it "includes the effective date" do
      search = EntrySearch.new(:conditions => {:effective_date => {:year => 2011}})
      
      search.summary.should == "Documents with an effective date in 2011"
    end
    
    it "includes the single agency" do
      agency = Factory(:agency, :name => "Commerce Department")
      search = EntrySearch.new(:conditions => {:agency_ids => [agency.id]})
      
      search.summary.should == "Documents from Commerce Department"
    end
    
    it "includes all agencies" do
      agency_1 = Factory(:agency, :name => "Commerce Department")
      agency_2 = Factory(:agency, :name => "State Department")
      search = EntrySearch.new(:conditions => {:agency_ids => [agency_1.id,agency_2.id]})
      
      search.summary.should == "Documents from Commerce Department or State Department"
    end
    
    it "includes the document type" do
      search = EntrySearch.new(:conditions => {:type => ['RULE','PRORULE']})
      search.summary.should == "Documents of type Rule or Proposed Rule"
    end
    
    it "includes the agency docket" do
      search = EntrySearch.new(:conditions => {:docket_id => 'EPA-HQ-OPPT-2005-0049'})
      search.summary.should == "Documents filed under agency docket EPA-HQ-OPPT-2005-0049"
    end
    
    it "includes the significance" do
      search = EntrySearch.new(:conditions => {:significant => '1'})
      search.summary.should == "Documents whose Associated Unified Agenda Deemed Significant Under EO 12866"
    end

    it "includes the affected CFR part" do
      search = EntrySearch.new(:conditions => {:cfr => {:title => '40', :part => '745'}})
      search.summary.should == "Documents affecting 40 CFR 745"
    end
    
    it "includes the location" do
      search = EntrySearch.new(:conditions => {:near => {:location => " 94118", :within => 50}})
      search.summary.should == "Documents located within 50 miles of  94118"
    end
    
    it "includes the section" do
      section = Factory(:section, :title => "Environment")
      search = EntrySearch.new(:conditions => {:section_ids => [section.id]})
      search.summary.should == "Documents in Environment"
    end
    
    it "includes the topic" do
      topic = Factory(:topic, :name => "Reporting and recordkeeping requirements")
      search = EntrySearch.new(:conditions => {:topic_ids => [topic.id]})
      search.summary.should == "Documents about Reporting and recordkeeping requirements"
    end
    
    it "combines multiple types of filters with the appropriate conjunction" do
      search = EntrySearch.new(:conditions => {
            :term => "fishing",
            :type => ['RULE','PRORULE'],
            :cfr => {:title => '45', :part => '745'}
      })
      search.summary.should == "Documents matching 'fishing', of type Rule or Proposed Rule, and affecting 45 CFR 745"
    end
  end
end
