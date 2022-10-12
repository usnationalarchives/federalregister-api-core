class EsEntrySearch::DateAggregator::Daily < EsEntrySearch::DateAggregator::Base

  def self.date_histogram_interval
    "day"
  end

  def periods
    periods = []

    date = @start_date
    while(date <= @end_date)
      periods << [date]
      date = date.advance(:days => 1)
    end

    periods
  end

  def es_format_str
    "%Y%m%d"
  end

  def name_format_str
    "%m/%d/%Y"
  end

end
