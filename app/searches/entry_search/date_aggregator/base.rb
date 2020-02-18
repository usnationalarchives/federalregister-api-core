class EntrySearch::DateAggregator::Base
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

  def raw_results
    group_and_counts = {}
    @sphinx_search.each_with_group_and_count do |entry, group_id, count|
      datetime = Time.at(group_id).utc
      group_and_counts[sphinx_format(datetime)] = count
    end

    group_and_counts
  end
  memoize :raw_results

  private

  def sphinx_format(date)
     date.strftime(sphinx_format_str)
 end

  def name_format(date)
    date.strftime(name_format_str)
  end
end
