require 'spec_helper'

describe Agency do
  it { should have_many :entries }
  
  describe "named_approximately" do
    before(:each) do
      @nasa = Agency.create!(:name => "National Aeronautics and Space Administration", :short_name => "NASA")
      @commission = Agency.create!(:name => "Commission on the Future of the United States Aerospace Industry")
      @international = Agency.create!(:name => "Agency for International Development")
      @office = Agency.create!(:name => "Administrative Office of United States Courts")
    end
    
    it "matches based on partial words" do
      Agency.named_approximately("Admin").should == [@office, @nasa]
    end
    
    it "should ignore word order" do
      Agency.named_approximately("Administration Space").should == [@nasa]
    end
    
    it "should match short_names" do
      Agency.named_approximately("NASA").should == [@nasa]
    end
    
    after(:each) do
      Agency.connection.execute("TRUNCATE agencies")
    end
  end
end