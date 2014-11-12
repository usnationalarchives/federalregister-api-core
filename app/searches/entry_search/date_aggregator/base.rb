class EntrySearch::DateAggregator::Base
  def initialize(sphinx_search, options)
    @sphinx_search = sphinx_search
    if options[:with] && options[:with][:publication_date]
      @start_date = Time.at(options[:with][:publication_date].first).utc.to_date
      @end_date = Time.at(options[:with][:publication_date].last).utc.to_date
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
    if !@raw_results
      client = @sphinx_search.send(:client)
      client.group_function = group_function
      client.group_by = "publication_date"
      client.limit = 5000
      
      query = @sphinx_search.send(:query)
      @raw_results = {}
      client.query(query, '*')[:matches].each do |match|
        @raw_results[match[:attributes]["@groupby"].to_s] = match[:attributes]["@count"]
      end
    end

    @raw_results
  end

  private

  def sphinx_format(date)
     date.strftime(sphinx_format_str)
 end

  def name_format(date)
    date.strftime(name_format_str)
  end
end
