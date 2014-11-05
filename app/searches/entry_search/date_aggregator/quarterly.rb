class EntrySearch::DateAggregator::Quarterly < EntrySearch::DateAggregator::Base
  def group_function
    :month
  end

  def periods
    periods = []

    date = @start_date.beginning_of_quarter
    while(date < @end_date)
      period = []
      3.times do
        period << date
        date = date.advance(:months => 1) 
      end
      periods << period
    end

    periods
  end

  def sphinx_format_str
    "%Y%m"
  end

  def name_format(date)
    date.strftime("Q#{(date.month-1)/3 + 1} %Y")
  end
end
