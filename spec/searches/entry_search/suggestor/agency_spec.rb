require "spec_helper"

describe 'EntrySearch::Suggestor::Agency' do
  def suggestor(term, options = {})
    conditions = options.merge(:term => term)
    EntrySearch::Suggestor::Agency.new(EsEntrySearch.new(:conditions => conditions))
  end

  describe "valid agency in search term" do
    before(:each) do
      @usda = Factory(:agency, slug: "agriculture-department", name: "Agriculture Department", short_name: "USDA", display_name: "Department of Agriculture")
      @hhs  = Factory(:agency, slug: "health-and-human-services-department", name: "Health and Human Services Department", short_name: "HHS", display_name: "Department of Health and Human Services")
      @fish = Factory(:agency, slug: "fish-department", name: "Fish Department")
    end

    it "should suggest an agency when matching a name identically" do
      suggestion = suggestor("Agriculture Department").suggestion
      suggestion.term.should == ''
      suggestion.agencies.should == [@usda.slug]
    end

    it "should suggest an agency when matching a short_name identically" do
      suggestion = suggestor("USDA").suggestion
      suggestion.term.should == ''
      suggestion.agencies.should == [@usda.slug]
    end

    it "should suggest an agency when containing a short_name" do
      suggestion = suggestor("HHS Rules").suggestion
      suggestion.term.should == ' Rules'
      suggestion.agencies.should == [@hhs.slug]
    end

    it "when a double-quote is included, should suggest an agency from string outside of quotes" do
      suggestion = suggestor('"goat" USDA').suggestion
      suggestion.agencies.should == [@usda.slug]
    end

    it "shouldn't suggest an agency who contains a short_name embedded in other words" do
      suggestion = suggestor("HHHSO Rules").suggestion
      suggestion.should be_nil
    end

    it "shouldn't suggest an agency that doesn't have a full match" do
      suggestion = suggestor("cult Rules").suggestion
      suggestion.should be_nil
    end

    it "shouldn't suggest an agency that is already selected" do
      suggestion = suggestor(@usda.name, :agencies => [@usda.slug]).suggestion
      suggestion.should be_nil
    end

    it "keep words separate" do
      suggestion = suggestor("before USDA after").suggestion
      suggestion.term.should == 'before  after'
    end

    it "not match hyphenated words" do
      suggestion = suggestor("pre-USDA").suggestion
      suggestion.should be_nil
    end

    it "doesn't match quoted words" do
      suggestion = suggestor('"425 USDA 123"').suggestion
      suggestion.should be_nil
    end

    it "doesn't match excluded words" do
      suggestion = suggestor('-USDA').suggestion
      suggestion.should be_nil
    end

    it "doesn't match exact words" do
      suggestion = suggestor('=USDA').suggestion
      suggestion.should be_nil
    end

    it "doesn't match exact excluded words" do
      suggestion = suggestor('-=USDA').suggestion
      suggestion.should be_nil
    end

    it "doesn't match an agency at the beginning of a hyphenated string" do
      suggestion = suggestor('USDA-1234-1234').suggestion
      suggestion.should be_nil
    end

  end

  it "returns the correct attachment url" do
    attachment = File.new(Rails.root + 'spec/fixtures/empty_example_file')
    result = Agency.new(logo: attachment)
    host = "https://#{Settings.app.aws.s3.host_aliases.agency_logos}"
    expect(result.logo.url).to start_with(host)
  end
end
