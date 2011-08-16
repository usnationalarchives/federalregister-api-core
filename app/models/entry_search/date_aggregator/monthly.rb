class EntrySearch::DateAggregator::Monthly < EntrySearch::DateAggregator::Base
  def group_function
    :month
  end

  def periods
    periods = []

    date = @start_date
    while(date < Date.current)
      periods << [date.strftime("%Y%m")]
      date = date.advance(:months => 1) 
    end

    periods
  end
end
