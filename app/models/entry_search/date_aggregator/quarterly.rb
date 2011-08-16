class EntrySearch::DateAggregator::Quarterly < EntrySearch::DateAggregator::Base
  def group_function
    :month
  end

  def periods
    periods = []

    date = @start_date.beginning_of_quarter
    while(date < Date.current)
      period = []
      3.times do
        period << date.strftime("%Y%m")
        date = date.advance(:months => 1) 
      end
      periods << period
    end

    periods
  end
end
