require 'test_helper'

class PotentialDateExtractorTest < ActiveSupport::TestCase
  def test_nil
    assert_equal([], PotentialDateExtractor.extract(nil))
  end
  
  def test_text_dates
    assert_equal(["January 3"], PotentialDateExtractor.extract("On January 3 foo bar 17 as 12"))
    assert_equal(["January 3rd"], PotentialDateExtractor.extract("On January 3rd foo bar 17 as 12"))
    assert_equal(["January the 3rd"], PotentialDateExtractor.extract("On January the 3rd foo bar 17 as 12"))
    assert_equal(["January 3rd, 2009"], PotentialDateExtractor.extract("On January 3rd, 2009 foo bar 17 as 12"))
    assert_equal(["January the 3rd, 2009"], PotentialDateExtractor.extract("On January the 3rd, 2009 foo bar 17 as 12"))
    assert_equal(["January 3 2009"], PotentialDateExtractor.extract("On January 3 2009 foo bar 17 as 12"))
    assert_equal(["January 3, 2009"], PotentialDateExtractor.extract("On January 3, 2009 foo bar 17 as 12"))
    assert_equal(["Jan 3, 2009"], PotentialDateExtractor.extract("On Jan 3, 2009 foo bar 17 as 12"))
    assert_equal(["Jan. 3, 2009"], PotentialDateExtractor.extract("On Jan. 3, 2009 foo bar 17 as 12"))
  end
  
  def test_us_dates
    assert_equal(["3/6/2009"], PotentialDateExtractor.extract("On 3/6/2009 foo bar 17 as 12"))
    assert_equal(["3/06/2009"], PotentialDateExtractor.extract("On 3/06/2009 foo bar 17 as 12"))
    assert_equal(["03/6/2009"], PotentialDateExtractor.extract("On 03/6/2009 foo bar 17 as 12"))
    assert_equal(["03/06/2009"], PotentialDateExtractor.extract("On 03/06/2009 foo bar 17 as 12"))
    assert_equal(["3/6/09"], PotentialDateExtractor.extract("On 3/6/09 foo bar 17 as 12"))
    assert_equal(["3/06/09"], PotentialDateExtractor.extract("On 3/06/09 foo bar 17 as 12"))
    assert_equal(["03/6/09"], PotentialDateExtractor.extract("On 03/6/09 foo bar 17 as 12"))
    assert_equal(["03/06/09"], PotentialDateExtractor.extract("On 03/06/09 foo bar 17 as 12"))
  end
  
  def test_iso_dates
    assert_equal(["2009-01-01"], PotentialDateExtractor.extract("On 2009-01-01 foo bar 17 as 12"))
    assert_equal(["2009-1-1"], PotentialDateExtractor.extract("On 2009-1-1 foo bar 17 as 12"))
    assert_equal(["09-01-01"], PotentialDateExtractor.extract("On 09-01-01 foo bar 17 as 12"))
    assert_equal(["09-1-1"], PotentialDateExtractor.extract("On 09-1-1 foo bar 17 as 12"))
  end
  
  def test_multiple_matches
    assert_equal(["January the 3rd, 2009", "2009-01-01"], PotentialDateExtractor.extract("On January the 3rd, 2009 foo bar 17 as 12 and 2009-01-01 was great"))
  end
  
  def test_not_too_aggressive
    assert_equal([], PotentialDateExtractor.extract("12:01"))
    assert_equal([], PotentialDateExtractor.extract("May 2009"))
    assert_equal([], PotentialDateExtractor.extract("2003, Pub. L.108-159 (2003)"))
    assert_equal([], PotentialDateExtractor.extract("36 CFR 242.3 and 50 CFR 100.3 of the subsistence"))
  end
end
