class EntrySearch::DateAggregator::Weekly < EntrySearch::DateAggregator::Base
  def group_function
    :week
  end

  def periods
    periods = []
    
    date = @start_date - @start_date.wday
    while(date <= Date.current)
      periods << [date.strftime("%Y%j")]
      date += 7
    end

    periods
  end
end
