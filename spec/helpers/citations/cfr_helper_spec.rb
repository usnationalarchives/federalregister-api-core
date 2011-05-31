describe Citations::CfrHelper do
  include Citations::CfrHelper
  
  describe 'add_cfr_links' do
    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10','100')) + '" target="_blank">10 CFR 100</a>'
    end
    
    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10','100')) + '" target="_blank">10 CFR 100</a>'
    end
    
    it "supports '# CFR #.#'" do
      add_cfr_links('10 CFR 100.1').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10', '100', '1')) + '" target="_blank">10 CFR 100.1</a>'
    end
    
    it "supports '# C.F.R. #.#'" do
      add_cfr_links('10 C.F.R. 100.1').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10','100','1')) + '" target="_blank">10 C.F.R. 100.1</a>'
    end
    
    it "supports '# C.F.R. Part #.#'" do
      add_cfr_links('10 C.F.R. Part 100.1').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10','100','1')) + '" target="_blank">10 C.F.R. Part 100.1</a>'
    end
    
    it "supports '# C.F.R. parts #'" do
      add_cfr_links('10 C.F.R. parts 100').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10', '100')) + '" target="_blank">10 C.F.R. parts 100</a>'
    end
    
    it "supports '# C.F.R. Sec. #'" do
      add_cfr_links('10 C.F.R. Sec. 100').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10', '100')) + '" target="_blank">10 C.F.R. Sec. 100</a>'
    end
    
    it "supports '# C.F.R. &#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7; 100').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10', '100')) + '" target="_blank">10 C.F.R. &#xA7; 100</a>'
    end
    
    it "supports '# C.F.R. &#xA7;&#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7;&#xA7; 100').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10','100')) + '" target="_blank">10 C.F.R. &#xA7;&#xA7; 100</a>'
    end
    
    it "supports multiple citations like '# CFR #.# and # CFR #.#'" do
      add_cfr_links('10 CFR 660.719 and 10 CFR 665.28').should == '<a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10','660','719')) + '" target="_blank">10 CFR 660.719</a> and <a class="cfr external" href="' + h(cfr_url(Time.current.to_date,'10','665','28')) + '" target="_blank">10 CFR 665.28</a>'
    end
    
    it "does not support title 26" do
      add_cfr_links("26 CFR 1").should == "26 CFR 1"
    end
    
    it "supports missing the initial space: '49 CFR230.105(c)'"
    it "supports '15 CFR parts 4 and 903'"
    it "supports '33 CFR Parts 160, 161, 164, and 165'"
    it "supports '18 CFR 385.214 or 385.211'"
    it "supports '7 CFR 2.22, 2.80, and 371.3'"
  end
  
  describe "cfr_url" do
    date = Date.parse("2010-06-15")
    
    it "uses FDSys" do
      cfr_url(date, "2","175").should match /^http:\/\/www\.gpo\.gov\/fdsys\//
    end
    
    it "assumes volume 1 if no volume in lookup table" do
      cfr_url(date, "2","175").should == 'http://www.gpo.gov/fdsys/pkg/CFR-2010-title2-vol1/xml/CFR-2010-title2-vol1-part175.xml'
    end
    
    it "uses lookup table as necessary" do
      cfr_url(date,"10","707").should == 'http://www.gpo.gov/fdsys/pkg/CFR-2010-title10-vol4/xml/CFR-2010-title10-vol4-part707.xml'
    end
    
    it "looks up the appropriate year to use" do
      cfr_url(date, "49","3").should == "http://www.gpo.gov/fdsys/pkg/CFR-2009-title49-vol1/xml/CFR-2009-title49-vol1-part3.xml"
    end
    
    it "supports sections" do
      cfr_url(date, "49","11","101").should == "http://www.gpo.gov/fdsys/pkg/CFR-2009-title49-vol1/xml/CFR-2009-title49-vol1-sec11-101.xml"
    end
  end
  
  describe "cfr_volume" do
    it "assumes volume 1 if no volume in lookup table" do
      cfr_volume(2010, "2","175").should == 1
    end
    it "uses lookup table as necessary" do
      cfr_volume(2010, "10","707").should == 4
    end
  end
  
  describe "cfr_edition" do
    # The annual update cycle is as follows: titles 1-16 are revised as of January 1; titles 17-27 are revised as of April 1; titles 28-41 are revised as of July 1; and titles 42-50 are revised as of October 1.
    it "returns the date's year if issue published 3 months after the date" do
      cfr_edition(1,Date.parse("2010-01-01")).should == 2009
      cfr_edition(1,Date.parse("2010-07-01")).should == 2010
      cfr_edition(27,Date.parse("2010-08-30")).should == 2010
    end
    it "returns the date's previous year if issue published after the date" do
      cfr_edition(17,Date.parse("2010-01-01")).should == 2009
      cfr_edition(17,Date.parse("2010-01-02")).should == 2009
      cfr_edition(50,Date.parse("2010-07-01")).should == 2009
    end
  end
end