require 'spec_helper'

describe PageViewCount do
  before(:each) do
    $redis = MockRedis.new
  end

  # Sets time in the specs ex. '2011-04-12' '2pm'
  def set_time(iso_date, time_string)
    allow(Date).to receive(:current).and_return(iso_date.to_date)
    allow(Time).to receive(:current).and_return(Time.find_zone('EST').parse("#{iso_date} #{time_string}"))
  end

  it "#update_all updates document counts as expected" do
    allow_any_instance_of(PageViewCount).to receive(:total_results).and_return(1)
    allow_any_instance_of(PageViewCount).to receive(:page_views).and_return(
      {"reports"=>
        [{"columnHeader"=>
           {"dimensions"=>["ga:pagePath"],
            "metricHeader"=>
             {"metricHeaderEntries"=>[{"name"=>"ga:pageviews", "type"=>"INTEGER"}]}},
          "data"=>
           {"rows"=>
             [{"dimensions"=>
                ["/articles/2015/10/16/2015-25597/2015-edition-health-information-technology-health-it-certification-criteria-2015-edition-base"],
               "metrics"=>[{"values"=>["8"]}]}],
            "rowCount"=>26159},
          "nextPageToken"=>"1"}]}
    )
    page_view_type = PageViewType::DOCUMENT

    set_time('2011-04-12', '2pm')
    PageViewCount.new(page_view_type).update_counts_for_today
    expect(PageViewCount.count_for('2015-25597', page_view_type)).to eq(8)

    set_time('2011-04-13', '12am')
    PageViewCount.new(page_view_type).update_counts_for_today
    expect(PageViewCount.count_for('2015-25597', page_view_type)).to eq(8)

    set_time('2011-04-13', '6am')
    PageViewCount.new(page_view_type).update_counts_for_today
    expect(PageViewCount.count_for('2015-25597', page_view_type)).to eq(8)
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
