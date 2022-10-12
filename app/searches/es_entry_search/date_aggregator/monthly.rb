class EsEntrySearch::DateAggregator::Monthly < EsEntrySearch::DateAggregator::Base

  def self.date_histogram_interval
    "month"
  end

  def periods
    periods = []

    date = @start_date
    while(date < @end_date)
      periods << [date]
      date = date.advance(:months => 1)
    end

    periods
  end

  def es_format_str
    "%Y%m"
  end

  def name_format_str
    "%B %Y"
  end
end
