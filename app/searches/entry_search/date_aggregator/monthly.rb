class EntrySearch::DateAggregator::Monthly < EntrySearch::DateAggregator::Base

  def self.group_by_field
    :publication_date_month
  end

  def group_function
    :month
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

  def sphinx_format_str
    "%Y%m"
  end

  def name_format_str
    "%B %Y"
  end
end
