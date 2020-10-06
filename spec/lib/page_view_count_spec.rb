require 'spec_helper'

describe PageViewCount do
  before(:each) do
    $redis = MockRedis.new
  end

  it "the regex for extracting document numbers is correct" do
    valid_urls = [
      "/public_inspection_documents/2012/03/30/2012-05896/disparate-impact-and-reasonable-factors-other-than-age-under-the-age-discrimination-in-employment",
      "/public-inspection/2012-05896/disparate-impact-and-reasonable-factors-other-than-age-under-the-age-discrimination-in-employment",
    ]
    regex = PageViewType.find_by_identifier('public_inspection_document').google_analytics_url_regex

    valid_urls.each do |url|
      result = url =~ regex
      expect(result).to eq(0)
    end


  end

  it "the regex doesn't mis-identify documents" do
    invalid_urls = [
      "/public-inspection/search",
      "/public-inspection/20-05896/disparate-impact-and-reasonable-factors-other-than-age-under-the-age-discrimination-in-employment",
    ]
    regex = PageViewType.find_by_identifier('public_inspection_document').google_analytics_url_regex

    invalid_urls.each do |url|
      result = url =~ regex
      expect(result).to eq(nil)
    end
  end

end
