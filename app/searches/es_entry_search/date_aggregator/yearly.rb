class EsEntrySearch::DateAggregator::Yearly < EsEntrySearch::DateAggregator::Base

  def self.date_histogram_interval
    "year"
  end

  def periods
    (@start_date.year .. @end_date.year).map{|year| [Date.new(year)]}
  end

  def es_format_str
    "%Y"
  end

  def name_format_str
    "%Y"
  end

end
