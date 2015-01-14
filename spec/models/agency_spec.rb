require 'spec_helper'

describe Agency do
  it { should have_many :entries }

  describe "named_approximately" do
    before(:each) do
      @nasa = Agency.create!(:name => "National Aeronautics and Space Administration", :short_name => "NASA")
      @commission = Agency.create!(:name => "Commission on the Future of the United States Aerospace Industry")
      @international = Agency.create!(:name => "Agency for International Development")
      @office = Agency.create!(:name => "Administrative Office of United States Courts")
      @prison = Agency.create!(:name => "Prison Department")
      @epa = Agency.create!(:name => "Environmental Protection Agency", :short_name => "EPA")
    end

    it "matches based on partial words" do
      Agency.named_approximately("Admin").should == [@office, @nasa]
    end

    it "ignores word order" do
      Agency.named_approximately("Administration Space").should == [@nasa]
    end

    it "matches short_names" do
      Agency.named_approximately("NASA").should == [@nasa]
    end

    it "ignores stop words" do
      Agency.named_approximately("National Aeronautics & Space Administration").should == [@nasa]
      Agency.named_approximately("The Administrative Office of United States Courts").should == [@office]
    end

    it "does not error out on numbers" do
      Agency.named_approximately("2979").should == []
    end

    it "only searches from the beginning of words" do
      Agency.named_approximately('epa').should == [@epa]
    end

    after(:each) do
      Agency.connection.execute("TRUNCATE agencies")
    end
  end
end
