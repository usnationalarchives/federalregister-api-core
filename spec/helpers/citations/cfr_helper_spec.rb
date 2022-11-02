require 'spec_helper'

describe Citations::CfrHelper, type: :helper do
  include RouteBuilder

  describe 'add_cfr_links' do

    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '" class="cfr external">10 CFR 100</a>'
    end

    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '" class="cfr external">10 CFR 100</a>'
    end

    it "supports '# CFR #.#'" do
      add_cfr_links('10 CFR 100.1').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100', '1')) + '" class="cfr external">10 CFR 100.1</a>'
    end

    it "supports '# C.F.R. #.#'" do
      add_cfr_links('10 C.F.R. 100.1').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '" class="cfr external">10 C.F.R. 100.1</a>'
    end

    it "supports '# C.F.R. Part #.#'" do
      add_cfr_links('10 C.F.R. Part 100.1').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '" class="cfr external">10 C.F.R. Part 100.1</a>'
    end

    it "supports '# C.F.R. parts #'" do
      add_cfr_links('10 C.F.R. parts 100').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '" class="cfr external">10 C.F.R. parts 100</a>'
    end

    it "supports '# C.F.R. Sec. #'" do
      add_cfr_links('10 C.F.R. Sec. 100').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '" class="cfr external">10 C.F.R. Sec. 100</a>'
    end

    it "supports '# C.F.R. &#xA7; #'" do
      result = add_cfr_links('10 C.F.R. &#xA7; 100')

      # expected_result_per_rails_2 = "<a class=\"cfr external\" href=\"/select-citation/2019/11/19/10-CFR-100\">10 C.F.R. &#xA7; 100</a>"
      expected_result_per_rails_3 = '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '" class="cfr external">10 C.F.R. &#xA7; 100</a>'
      expect(result).to eq(expected_result_per_rails_3)
    end

    it "supports '# C.F.R. &#xA7;&#xA7; #'" do
      result = add_cfr_links('10 C.F.R. &#xA7;&#xA7; 100')

      # expected_result_per_rails_2 = "<a class=\"cfr external\" href=\"/select-citation/2019/11/19/10-CFR-100\">10 C.F.R. &#xA7;&#xA7; 100</a>"
      expected_result_per_rails_3 = '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '" class="cfr external">10 C.F.R. &#xA7;&#xA7; 100</a>'
      expect(result). to eq(expected_result_per_rails_3)
    end

    it "supports multiple citations like '# CFR #.# and # CFR #.#'" do
      add_cfr_links('10 CFR 660.719 and 10 CFR 665.28').should == '<a href="' + h(select_cfr_citation_path(Time.current.to_date,'10','660','719')) + '" class="cfr external">10 CFR 660.719</a> and <a href="' + h(select_cfr_citation_path(Time.current.to_date,'10','665','28')) + '" class="cfr external">10 CFR 665.28</a>'
    end

    # it "supports missing the initial space: '49 CFR230.105(c)'"
    # it "supports '15 CFR parts 4 and 903'"
    # it "supports '33 CFR Parts 160, 161, 164, and 165'"
    # it "supports '18 CFR 385.214 or 385.211'"
    # it "supports '7 CFR 2.22, 2.80, and 371.3'"
  end
end
