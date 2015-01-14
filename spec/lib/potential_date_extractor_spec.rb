require 'spec_helper'

describe PotentialDateExtractor do
  describe "#extract" do
    it "supports nils" do
      PotentialDateExtractor.extract(nil).should == []
    end

    it "matches textual dates" do
      PotentialDateExtractor.extract("On January 3 2009 foo bar 17 as 12").should == ["January 3 2009"]
      PotentialDateExtractor.extract("On Jan 3 2009 foo bar 17 as 12").should == ["Jan 3 2009"]
      PotentialDateExtractor.extract("On Jan. 3 2009 foo bar 17 as 12").should == ["Jan. 3 2009"]
    end

    it "does not match textual dates without years" do
      PotentialDateExtractor.extract("On January 3 foo bar 17 as 12").should == []
      PotentialDateExtractor.extract("On January 3rd foo bar 17 as 12").should == []
    end

    it "requires separators in textual dates" do
      PotentialDateExtractor.extract("On January 3rd2009 foo bar 17 as 12").should == []
      PotentialDateExtractor.extract("On January 32009 foo bar 17 as 12").should == []
      PotentialDateExtractor.extract("On Jan 32009 foo bar 17 as 12").should == []
      PotentialDateExtractor.extract("On Jan. 32009 foo bar 17 as 12").should == []
    end

    it "matches US-style dates" do
      PotentialDateExtractor.extract("On 3/6/2009 foo bar 17 as 12").should == ["3/6/2009"]
      PotentialDateExtractor.extract("On 03/6/2009 foo bar 17 as 12").should == ["03/6/2009"]
      PotentialDateExtractor.extract("On 03/06/2009 foo bar 17 as 12").should == ["03/06/2009"]
      PotentialDateExtractor.extract("On 3/6/09 foo bar 17 as 12").should == ["3/6/09"]
      PotentialDateExtractor.extract("On 3/06/09 foo bar 17 as 12").should == ["3/06/09"]
      PotentialDateExtractor.extract("On 03/6/09 foo bar 17 as 12").should == ["03/6/09"]
      PotentialDateExtractor.extract("On 03/06/09 foo bar 17 as 12").should == ["03/06/09"]
    end

    it "finds multiple matches in one string" do
      PotentialDateExtractor.extract("On January 3rd, 2009 foo bar 17 as 12 and 01/01/2009 was great").should == ["January 3rd, 2009", "01/01/2009"]
    end

    it "does not match non-dates" do
      [
        "On 2009-01-01 foo bar 17 as 12",
        "On 09-01-01 foo bar 17 as 12",
        "On 09-1-1 foo bar 17 as 12",
        'May 2009',
        '2003, Pub. L.108-159 (2003)',
        '12:01',
        '36 CFR 242.3 and 50 CFR 100.3 of the subsistence',
        'at coordinates 44-22-48 NL, and 108- 02-18 WL',
        'at coordinates 44-22-48 NL, and 08- 02-18 WL',
        'Case no. R-S/07-10)'
      ].each do |str|
        PotentialDateExtractor.extract(str).should == []
      end
    end
  end
end