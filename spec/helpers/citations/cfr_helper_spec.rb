require 'spec_helper'

describe Citations::CfrHelper do
  include Citations::CfrHelper
  include RouteBuilder
  include ActionView::Helpers::TagHelper

  describe 'add_cfr_links' do
    def default_url_options
      {}
    end

    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 CFR 100</a>'
    end

    it "supports '# CFR #'" do
      add_cfr_links('10 CFR 100').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 CFR 100</a>'
    end

    it "supports '# CFR #.#'" do
      add_cfr_links('10 CFR 100.1').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100', '1')) + '">10 CFR 100.1</a>'
    end

    it "supports '# C.F.R. #.#'" do
      add_cfr_links('10 C.F.R. 100.1').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '">10 C.F.R. 100.1</a>'
    end

    it "supports '# C.F.R. Part #.#'" do
      add_cfr_links('10 C.F.R. Part 100.1').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '">10 C.F.R. Part 100.1</a>'
    end

    it "supports '# C.F.R. parts #'" do
      add_cfr_links('10 C.F.R. parts 100').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. parts 100</a>'
    end

    it "supports '# C.F.R. Sec. #'" do
      add_cfr_links('10 C.F.R. Sec. 100').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. Sec. 100</a>'
    end

    it "supports '# C.F.R. &#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7; 100').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. &#xA7; 100</a>'
    end

    it "supports '# C.F.R. &#xA7;&#xA7; #'" do
      add_cfr_links('10 C.F.R. &#xA7;&#xA7; 100').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 C.F.R. &#xA7;&#xA7; 100</a>'
    end

    it "supports multiple citations like '# CFR #.# and # CFR #.#'" do
      add_cfr_links('10 CFR 660.719 and 10 CFR 665.28').should == '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','660','719')) + '">10 CFR 660.719</a> and <a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','665','28')) + '">10 CFR 665.28</a>'
    end

    it "supports missing the initial space: '49 CFR230.105(c)'"
    it "supports '15 CFR parts 4 and 903'"
    it "supports '33 CFR Parts 160, 161, 164, and 165'"
    it "supports '18 CFR 385.214 or 385.211'"
    it "supports '7 CFR 2.22, 2.80, and 371.3'"
  end
end
