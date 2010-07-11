describe CitationsHelper do
  include CitationsHelper
  
  describe 'add_usc_links' do
    it "supports '# USC #'" do
      add_usc_links('10 USC 1').should == '<a class="usc external" href="' + h(usc_url('10', '1')) + '" target="_blank">10 USC 1</a>'
    end
    
    it "supports '# U.S.C. #'" do
      add_usc_links('10 U.S.C. 1').should == '<a class="usc external" href="' + h(usc_url('10', '1')) + '" target="_blank">10 U.S.C. 1</a>'
    end
    
    it "supports '39 U.S.C. 3632, 3633, or 3642'"
    it "supports '39 U.S.C. 3632, 3633, or 3642 and 39 CFR part 3015'"
  end
  
  describe 'add_cfr_links' do
    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a class="cfr external" href="' + h(cfr_url('10','100')) + '" target="_blank">10 CFR 100</a>'
    end
    
    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a class="cfr external" href="' + h(cfr_url('10','100')) + '" target="_blank">10 CFR 100</a>'
    end
    
    it "supports '# CFR #.#'" do
      add_cfr_links('10 CFR 100.1').should == '<a class="cfr external" href="' + h(cfr_url('10', '100', '1')) + '" target="_blank">10 CFR 100.1</a>'
    end
    
    it "supports '# C.F.R. #.#'" do
      add_cfr_links('10 C.F.R. 100.1').should == '<a class="cfr external" href="' + h(cfr_url('10','100','1')) + '" target="_blank">10 C.F.R. 100.1</a>'
    end
    
    it "supports '# C.F.R. Part #.#'" do
      add_cfr_links('10 C.F.R. Part 100.1').should == '<a class="cfr external" href="' + h(cfr_url('10','100','1')) + '" target="_blank">10 C.F.R. Part 100.1</a>'
    end
    
    it "supports '# C.F.R. parts #'" do
      add_cfr_links('10 C.F.R. parts 100').should == '<a class="cfr external" href="' + h(cfr_url('10', '100')) + '" target="_blank">10 C.F.R. parts 100</a>'
    end
    
    it "supports '# C.F.R. Sec. #'" do
      add_cfr_links('10 C.F.R. Sec. 100').should == '<a class="cfr external" href="' + h(cfr_url('10', '100')) + '" target="_blank">10 C.F.R. Sec. 100</a>'
    end
    
    it "supports '# C.F.R. &#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7; 100').should == '<a class="cfr external" href="' + h(cfr_url('10', '100')) + '" target="_blank">10 C.F.R. &#xA7; 100</a>'
    end
    
    it "supports '# C.F.R. &#xA7;&#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7;&#xA7; 100').should == '<a class="cfr external" href="' + h(cfr_url('10','100')) + '" target="_blank">10 C.F.R. &#xA7;&#xA7; 100</a>'
    end
    
    it "supports multiple citations like '# CFR #.# and # CFR #.#'" do
      add_cfr_links('50 CFR 660.719 and 50 CFR 665.28').should == '<a class="cfr external" href="' + h(cfr_url('50','660','719')) + '" target="_blank">50 CFR 660.719</a> and <a class="cfr external" href="' + h(cfr_url('50','665','28')) + '" target="_blank">50 CFR 665.28</a>'
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
      add_public_law_links("Public Law 107-295").should == '<a class="publ external" href="' + h(public_law_url('107','295')) + '" target="_blank">Public Law 107-295</a>'
    end
    
    it "supports 'Pub. Law #-#'" do
      add_public_law_links("Pub. Law 107-295").should == '<a class="publ external" href="' + h(public_law_url('107','295')) + '" target="_blank">Pub. Law 107-295</a>'
    end
    
    it "supports 'Pub. L. #-#'" do
      add_public_law_links("Pub. L. 107-295").should == '<a class="publ external" href="' + h(public_law_url('107', '295')) + '" target="_blank">Pub. L. 107-295</a>'
    end
    
    it "supports 'P.L. #-#'" do
      add_public_law_links("P.L. 107-295").should == '<a class="publ external" href="' + h(public_law_url('107', '295')) + '" target="_blank">P.L. 107-295</a>'
    end
  end
  
  describe 'add_patent_links' do
    it "supports 'Patent Number #'" do
      add_patent_links('Patent Number 4,954,320').should == '<a class="patent external" href="' + h(patent_url('4,954,320')) + '" target="_blank">Patent Number 4,954,320</a>'
    end
    
    it "supports 'Patent Application Number 08/331,554'"
  end
  
  describe 'add_navy_case_links' do
    it "supports 'Navy Case Number 97567'"
  end
  
  describe 'adding links to HTML' do
    it 'should not interfere with existing links' do
      add_citation_links('<a href="#">10 CFR 100</a>').should == '<a href="#">10 CFR 100</a>'
    end
    
    it 'should not interfere with existing HTML but add its own links' do
      add_citation_links('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta 101 CFR 10 omega</em></p>').should == ('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta <a class="cfr external" href="' +  h(cfr_url('101','10')) + '" target="_blank">101 CFR 10</a> omega</p>')
    end
  end
end