class EsEntrySearch::DateAggregator::Weekly < EsEntrySearch::DateAggregator::Base

  def self.date_histogram_interval
    "week"
  end

  def periods
    periods = []

    date = @start_date - @start_date.wday + 1
    while(date <= @end_date)
      periods << (0..4).map{|i| date+i}

      date += 7
    end

    periods
  end

  def es_format_str
    "%Y%j"
  end

  def name_format_str
    "%Y Week %W"
  end

end
