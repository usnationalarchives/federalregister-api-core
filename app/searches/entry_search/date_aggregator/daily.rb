class EntrySearch::DateAggregator::Daily < EntrySearch::DateAggregator::Base
  def group_function
    :day
  end

  def periods
    periods = []

    date = @start_date.beginning_of_quarter
    while(date < @end_date)
      periods << [date]
      date = date.advance(:days => 1) 
    end

    periods
  end

  def sphinx_format_str
    "%Y%m%d"
  end

  def name_format_str
    "%m/%d/%Y"
  end
end
