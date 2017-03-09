class EntrySearch::DateAggregator::Weekly < EntrySearch::DateAggregator::Base
  def group_function
    :week
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

  def sphinx_format_str
    "%Y%j"
  end

  def name_format_str
    "%Y Week %W"
  end
end
