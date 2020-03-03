class EsEntrySearch::DateAggregator::Base
  extend Memoist

  def initialize(sphinx_search, options)
    @sphinx_search = sphinx_search
    if options[:with] && options[:with][:publication_date]
      @start_date = Time.at(options[:with][:publication_date].first).utc.to_date

      end_date = Time.at(options[:with][:publication_date].last).utc.to_date
      @end_date = end_date > Issue.current.publication_date ? Issue.current.publication_date : end_date
    else
      @start_date = Date.new(1994,1,1)
      @end_date = Issue.current.publication_date
    end
  end

  def counts
    periods.map{|sub_periods| sub_periods.map{|p| raw_results[sphinx_format(p)] || 0}.sum }
  end

  def results
    periods.each_with_object(Hash.new) do |sub_periods, hsh|
      identifier = sub_periods.first
      hsh[identifier.to_s(:iso)] = {
        :count => sub_periods.map{|p| raw_results[sphinx_format(p)] || 0}.sum,
        :name => name_format(identifier)
      }
    end
  end

  # The desired results
  # return {"1994"=>33337, "1995"=>31707, "1996"=>33132, "1997"=>34218, "1998"=>34743, "1999"=>34066, "2008"=>31812, "2009"=>30662, "2001"=>31984, "2000"=>33302, "2005"=>32226, "2004"=>32367, "2002"=>33075, "2003"=>32792, "2006"=>31501, "2007"=>30830, "2010"=>32465, "2011"=>33103, "2012"=>30875, "2013"=>30771}
  def raw_results
    group_and_counts = {}
    sphinx_search.aggregation_buckets.map do |term|
      datetime = Date.parse(term['key_as_string']) #TODO: Do we need to handle UTC processing parallel to what's happening in the Sphinx-based base.rb class?

      group_and_counts[sphinx_format(datetime)] = term.doc_count
    end

    group_and_counts
  end
  memoize :raw_results

  private

  attr_reader :sphinx_search

  def sphinx_format(date)
    date.strftime(sphinx_format_str)
  end

  def name_format(date)
    date.strftime(name_format_str)
  end

end
