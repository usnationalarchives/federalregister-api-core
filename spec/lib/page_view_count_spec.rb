require 'spec_helper'

describe PageViewCount do
  before(:each) do
    $redis = MockRedis.new
  end

  it "the regex for extracting document numbers is correct" do
    sample_url = "/public_inspection_documents/2012/03/30/2012-05896/disparate-impact-and-reasonable-factors-other-than-age-under-the-age-discrimination-in-employment"
    regex = PageViewType.find_by_identifier('public_inspection_document').google_analytics_url_regex
    result = sample_url =~ regex
    expect(result).to eq(0)
  end

end
