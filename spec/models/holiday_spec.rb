require 'spec_helper'

describe Holiday do
  describe "find_by_date" do
    it "returns a holiday object when given a string of the date of a US holiday" do
      Holiday.find_by_date('2010-01-01').should be_a Holiday
    end

    it "returns a holiday object when given a date object for the date of a US holiday" do
      Holiday.find_by_date(Date.parse('2010-01-01')).should be_a Holiday
    end

    it "returns nil when given a date that is not a US holiday" do
      Holiday.find_by_date('2010-01-02').should be nil
      Holiday.find_by_date(Date.parse('2010-01-02')).should be nil
    end
  end

  describe "name" do
    it "should return the name of the holiday" do
      Holiday.new(Date.parse('2010-01-01'), "New Year's Day").name.should == "New Year's Day"
    end
  end

  describe "date" do
    it "should return the date of the holiday" do
      Holiday.new(Date.parse('2010-01-01'), "New Year's Day").date.should == Date.parse("2010-01-01")
    end
  end
end
