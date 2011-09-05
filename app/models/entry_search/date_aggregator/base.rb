class EntrySearch::DateAggregator::Base
  def initialize(sphinx_search, options)
    @sphinx_search = sphinx_search
    @start_date = options[:since].to_date
  end

  def results
    periods.map{|sub_periods| sub_periods.map{|p| raw_results[p] || 0}.sum }
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
end
