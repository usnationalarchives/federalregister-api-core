class EntrySearch::DateAggregator::Yearly < EntrySearch::DateAggregator::Base
  def group_function
    :year
  end

  def periods
    (@start_date.year .. @end_date.year).map{|year| Date.new(year)}.map(&:to_a)
  end

  def sphinx_format_str
    "%Y"
  end

  def name_format_str
    "%Y"
  end
end
