require 'spec_helper'

describe EffectiveDateGenerator do

  it "returns an error if a date range larger than 120 days is requested" do
    expect do
      EffectiveDateGenerator.
        new.
        perform(
          Date.new(2019,1,1),
          Date.new(2019,5,3)
        )
    end.to raise_error(EffectiveDateGenerator::DateRangeTooLarge)
  end

  it "returns the correct date in a normal (non-weekend/non-holiday) scenario" do
    result = EffectiveDateGenerator.
      new.
      perform(
        Date.new(2019,3,1),
        Date.new(2019,3,1)
      )

    result['2019-03-01'][90].should == {
      :date          => "2019-05-30",
      :delay_reasons => []
    }
  end

  it "returns the correct date in a weekend scenario" do
    result = EffectiveDateGenerator.
      new.
      perform(
        Date.new(2019,3,1),
        Date.new(2019,3,1)
      )

    result['2019-03-01'][15].should == {
      :date          => "2019-03-18",
      :delay_reasons => ['weekend']
    }
  end

  it "returns the correct date in a weekend/holiday scenario" do
    result = EffectiveDateGenerator.
      new.
      perform(
        Date.new(2019,3,27),
        Date.new(2019,3,27)
      )

    result['2019-03-27'][60].should == {
      :date          => "2019-05-28",
      :delay_reasons => ['weekend','Memorial Day']
    }
  end

  it "takes into account newly_added EO holidays (e.g. Christmas Eve)" do
    result = EffectiveDateGenerator.
      new.
      perform(
        Date.new(2018,12,7),
        Date.new(2018,12,7)
      )

    result['2018-12-07'][15].should == {
      :date          => "2018-12-26",
      :delay_reasons => [
        "weekend",
        "Extension of Christmas Holiday (E.O. 13854)",
        "Christmas Day",
      ]
    }
  end

end
