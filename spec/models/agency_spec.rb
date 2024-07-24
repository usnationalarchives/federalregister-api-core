require 'spec_helper'

describe Agency do
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

  it "returns the correct attachment url" do
    attachment = File.new(Rails.root + 'spec/fixtures/empty_example_file')
    result = Agency.new(logo: attachment).logo.url
    host = "https://#{Settings.app.aws.s3.host_aliases.agency_logos}"
    expect(result).to start_with(host)
  end

  describe "#pai_compilation_url" do
    it "adds an '-interim' suffix if the latest year is the interim year" do
      agency = Agency.new(pai_year: 2025, pai_identifier: "SSA")
      expect(agency.pai_compilation_url).to eq("https://www.govinfo.gov/content/pkg/PAI-2025-SSA-interim/xml/PAI-2025-SSA-interim.xml")
    end

    it "links 2007 post URLs to XML links" do
      agency = Agency.new(pai_year: 2023, pai_identifier: "FDIC")
      expect(agency.pai_compilation_url).to eq("https://www.govinfo.gov/content/pkg/PAI-2023-FDIC/xml/PAI-2023-FDIC.xml")
    end

    it "links pre-2007 URLs to text links since XML does not exist" do
      agency = Agency.new(pai_year: 2005, pai_identifier: "ARCHITEC")
      expect(agency.pai_compilation_url).to eq("https://www.govinfo.gov/content/pkg/PAI-2005-ARCHITEC/html/PAI-2005-ARCHITEC.html")
    end

  end

end
