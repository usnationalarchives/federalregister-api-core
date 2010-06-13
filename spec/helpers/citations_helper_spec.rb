describe CitationsHelper do
  include CitationsHelper
  
  describe 'add_usc_links' do
    it "supports '# USC #'" do
      add_usc_links('10 USC 1').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&amp;docid=Cite:+10USC1" class="usc external" target="_blank">10 USC 1</a>'
    end
    
    it "supports '# U.S.C. #'" do
      add_usc_links('10 U.S.C. 1').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&amp;docid=Cite:+10USC1" class="usc external" target="_blank">10 U.S.C. 1</a>'
    end
    
    it "supports '39 U.S.C. 3632, 3633, or 3642'"
    it "supports '39 U.S.C. 3632, 3633, or 3642 and 39 CFR part 3015'"
  end
  
  describe 'add_cfr_links' do
    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 CFR 100</a>'
    end
    
    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 CFR 100</a>'
    end
    
    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100.1').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=1&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 CFR 100.1</a>'
    end
    
    it "supports '# C.F.R. #'" do
      add_cfr_links('10 C.F.R. 100.1').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=1&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 C.F.R. 100.1</a>'
    end
    
    it "supports '# C.F.R. Part #.#'" do
      add_cfr_links('10 C.F.R. Part 100.1').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=1&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 C.F.R. Part 100.1</a>'
    end
    
    it "supports '# CFR #.#(#)'" do
      add_cfr_links('18 CFR 806.22(f)').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=18&amp;PART=806&amp;SECTION=22&amp;SUBPART=f&amp;TYPE=TEXT" class="cfr external" target="_blank">18 CFR 806.22(f)</a>'
    end
    
    it "supports '# C.F.R. parts #'" do
      add_cfr_links('10 C.F.R. parts 100').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 C.F.R. parts 100</a>'
    end
    
    it "supports '# C.F.R. Sec. #'" do
      add_cfr_links('10 C.F.R. Sec. 100').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 C.F.R. Sec. 100</a>'
    end
    
    it "supports '# C.F.R. &#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7; 100').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 C.F.R. &#xA7; 100</a>'
    end
    
    it "supports '# C.F.R. &#xA7;&#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7;&#xA7; 100').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=10&amp;PART=100&amp;SECTION=&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">10 C.F.R. &#xA7;&#xA7; 100</a>'
    end
    
    it "supports multiple citations like '# CFR #.# and # CFR #.#'" do
      add_cfr_links('50 CFR 660.719 and 50 CFR 665.28').should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=50&amp;PART=660&amp;SECTION=719&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">50 CFR 660.719</a> and <a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&amp;TITLE=50&amp;PART=665&amp;SECTION=28&amp;SUBPART=&amp;TYPE=TEXT" class="cfr external" target="_blank">50 CFR 665.28</a>'
    end
    
    it "supports missing the initial space: '49 CFR230.105(c)'"
    it "supports '15 CFR parts 4 and 903'"
    it "supports '33 CFR Parts 160, 161, 164, and 165'"
    it "supports '18 CFR 385.214 or 385.211'"
    it "supports '7 CFR 2.22, 2.80, and 371.3'"
  end
  
  describe 'add_regulatory_plan_links' do
    it "links RINs to the appropriate regulation page" do
      add_regulatory_plan_links("See RIN 1234-ABCD and RIN 1234-ABCF").should == 'See <a href="/r/1234-ABCD">RIN 1234-ABCD</a> and <a href="/r/1234-ABCF">RIN 1234-ABCF</a>'
    end
  end
  
  describe 'add_federal_register_links' do
    it "links post 1994 FR citations to this site" do
      add_federal_register_links('60 FR 1000').should == '<a href="/citation/60/1000">60 FR 1000</a>'
    end
    
    it "does nothing with pre-1994 FR citations" do
      add_federal_register_links('10 FR 1000').should == '10 FR 1000'
    end
  end
  
  describe 'add_public_law_links' do
    it "supports 'Public Law #-#'" do
      add_public_law_links("Public Law 107-295").should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=107_cong_public_laws&amp;docid=f:publ295.107" class="publ external" target="_blank">Public Law 107-295</a>'
    end
    
    it "supports 'Pub. Law #-#'" do
      add_public_law_links("Pub. Law 107-295").should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=107_cong_public_laws&amp;docid=f:publ295.107" class="publ external" target="_blank">Pub. Law 107-295</a>'
    end
    
    it "supports 'Pub. L. #-#'" do
      add_public_law_links("Pub. L. 107-295").should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=107_cong_public_laws&amp;docid=f:publ295.107" class="publ external" target="_blank">Pub. L. 107-295</a>'
    end
    
    it "supports 'P.L. #-#'" do
      add_public_law_links("P.L. 107-295").should == '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=107_cong_public_laws&amp;docid=f:publ295.107" class="publ external" target="_blank">P.L. 107-295</a>'
    end
  end
  
  describe 'add_patent_links' do
    it "supports 'Patent Number #'" do
      add_patent_links('Patent Number 4,954,320').should == '<a href="http://patft.uspto.gov/netacgi/nph-Parser?Sect2=PTO1&amp;Sect2=HITOFF&amp;p=1&amp;u=/netahtml/PTO/search-bool.html&amp;r=1&amp;f=G&amp;l=50&amp;d=PALL&amp;RefSrch=yes&amp;Query=PN/4954320" class="patent external" target="_blank">Patent Number 4,954,320</a>'
    end
    
    it "supports 'Patent Application Number 08/331,554'"
  end
  
  describe 'add_navy_case_links' do
    it "suppoirts 'Navy Case Number 97567'"
  end
end