require 'spec_helper'
require 'sidekiq/testing'

describe PageViewCount do
  before(:each) do
    $redis = MockRedis.new
  end

  let(:total_results) { 1 }
  let(:page_views) {
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
  }

  # Sets time in the specs ex. '2011-04-12' '2pm'
  def set_time(iso_date, time_string)
    allow(Date).to receive(:current).and_return(iso_date.to_date)
    allow(Time).to receive(:current).and_return(Time.find_zone('EST').parse("#{iso_date} #{time_string}"))
  end

  it "the PageViewHistoricalSetUpdater updates counts as expected" do
    page_view_type = PageViewType::DOCUMENT
    allow_any_instance_of(PageViewHistoricalSetUpdater).to receive(:total_results).and_return(total_results)
    allow_any_instance_of(PageViewHistoricalSetUpdater).to receive(:page_views).and_return(page_views)
    Sidekiq::Testing.inline! do
      PageViewHistoricalSetUpdater.perform_async(
        (Date.new(2010,1,1)).to_s(:iso),
        Date.new(2010,3,31).to_s(:iso),
        page_view_type.id
      )
      expect(PageViewCount.count_for('2015-25597', page_view_type)).to eq(8)
      PageViewHistoricalSetUpdater.perform_async(
        (Date.new(2010,4,1)).to_s(:iso),
        Date.new(2010,6,30).to_s(:iso),
        page_view_type.id
      )
      expect(PageViewCount.count_for('2015-25597', page_view_type)).to eq(16)
    end

  end

  it "#update_all updates document counts as expected" do
    Timecop.freeze(Date.new(2020,10,19) )
    page_view_type = PageViewType::DOCUMENT
    allow_any_instance_of(PageViewHistoricalSetUpdater).to receive(:total_results).and_return(total_results)
    allow_any_instance_of(PageViewHistoricalSetUpdater).to receive(:page_views).and_return(page_views)
    allow_any_instance_of(PageViewCount).to receive(:total_results).and_return(total_results)
    allow_any_instance_of(PageViewCount).to receive(:page_views).and_return(page_views)

    Sidekiq::Testing.inline! do
      PageViewCount.new(page_view_type).update_all
    end

    expect(PageViewCount.count_for('2015-25597', page_view_type)).to eq(360)
  end

  it "#update_counts_for_today updates document counts as expected" do
    allow_any_instance_of(PageViewCount).to receive(:total_results).and_return(total_results)
    allow_any_instance_of(PageViewCount).to receive(:page_views).and_return(page_views)
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

  it "calculates periods correctly" do
    Timecop.freeze(Time.local(2020, 10, 15, 10, 5, 0))
    date_ranges = PageViewCount.new(PageViewType.first).send(:date_ranges,2019,2020)

    expect(date_ranges).to eq([
      Date.new(2019,1,1)..Date.new(2019,3,31),
      Date.new(2019,4,1)..Date.new(2019,6,30),
      Date.new(2019,7,1)..Date.new(2019,9,30),
      Date.new(2019,10,1)..Date.new(2019,12,31),
      Date.new(2020,1,1)..Date.new(2020,3,31),
      Date.new(2020,4,1)..Date.new(2020,6,30),
      Date.new(2020,7,1)..Date.new(2020,9,30),
      Date.new(2020,10,1)..Date.new(2020,10,14),
    ])
  end

end
