require 'spec_helper'

describe CitationsHelper, type: :helper do
  include Citations::CfrHelper
  include HtmlHelper
  include RouteBuilder

  describe 'add_eo_links' do
    [
      'Executive Order 12944',
      'EO 12944',
      'E. O. 12944',
      'E.O. 12944',
      'Executive Order No 12944',
      'Executive Order No. 12,944'
    ].each do |citation|
      it "supports '#{citation}'" do
        add_eo_links(citation).should == '<a href="' + executive_order_path(12944) + '" class="eo">' + citation + '</a>'
      end
    end
  end
  describe 'add_usc_links' do
    it "supports '# USC #'" do
      add_usc_links('10 USC 1').should == '<a href="' + h(usc_url('10', '1')) + '" class="usc external" target="_blank">10 USC 1</a>'
    end

    it "supports '# U.S.C. #'" do
      add_usc_links('10 U.S.C. 1').should == '<a href="' + h(usc_url('10', '1')) + '" class="usc external" target="_blank">10 U.S.C. 1</a>'
    end

    # it "supports '39 U.S.C. 3632, 3633, or 3642'"
    # it "supports '39 U.S.C. 3632, 3633, or 3642 and 39 CFR part 3015'"
  end

  describe 'add_regulatory_plan_links' do
    it "links RINs to the appropriate regulation page" do
      add_regulatory_plan_links("See RIN 1234-AB12 and RIN 1234-AB34").should == 'See RIN <a href="/r/1234-AB12">1234-AB12</a> and RIN <a href="/r/1234-AB34">1234-AB34</a>'
    end
  end

  describe 'add_federal_register_links' do
    it "links post 1994 FR citations to this site" do
      add_federal_register_links('60 FR 1000').should == '<a href="/citation/60-FR-1000">60 FR 1000</a>'
    end

    it "does nothing with pre-1994 FR citations" do
      add_federal_register_links('10 FR 1000').should == '10 FR 1000'
    end
  end

  describe 'add_public_law_links' do
    it "supports 'Public Law #-#'" do
      add_public_law_links("Public Law 107-295").should == '<a href="' + h(public_law_url('107','295')) + '" class="publ external" target="_blank">Public Law 107-295</a>'
    end

    it "supports 'Pub. Law #-#'" do
      add_public_law_links("Pub. Law 107-295").should == '<a href="' + h(public_law_url('107','295')) + '" class="publ external" target="_blank">Pub. Law 107-295</a>'
    end

    it "supports 'Pub. L. #-#'" do
      add_public_law_links("Pub. L. 107-295").should == '<a href="' + h(public_law_url('107', '295')) + '" class="publ external" target="_blank">Pub. L. 107-295</a>'
    end

    it "supports 'P.L. #-#'" do
      add_public_law_links("P.L. 107-295").should == '<a href="' + h(public_law_url('107', '295')) + '" class="publ external" target="_blank">P.L. 107-295</a>'
    end
  end

  describe 'add_patent_links' do
    it "supports 'Patent Number #'" do
      add_patent_links('Patent Number 4,954,320').should == '<a href="' + h(patent_url('4,954,320')) + '" class="patent external" target="_blank">Patent Number 4,954,320</a>'
    end

    # it "supports 'Patent Application Number 08/331,554'"
  end

  # describe 'add_navy_case_links' do
  #   it "supports 'Navy Case Number 97567'"
  # end

  describe 'adding links to HTML' do
    it 'should not interfere with existing links' do
      add_citation_links('<a href="#">10 CFR 100</a>').should == '<a href="#">10 CFR 100</a>'
    end

    it 'should not interfere with existing HTML but add its own links' do
      add_citation_links('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta 10 CFR 10 omega</em></p>').should == ('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta <a href="' +  h(select_cfr_citation_path(Time.current.to_date, '10','10')) + '" class="cfr external">10 CFR 10</a> omega</p>')
    end
  end
end
