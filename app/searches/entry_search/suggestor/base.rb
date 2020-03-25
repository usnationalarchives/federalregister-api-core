class EntrySearch::Suggestor::Base
  def initialize(search)
    @search = search
    if @search.term.present?
      matchdata = @search.term.match(pattern)

      if matchdata
        @conditions = @search.conditions.dup
        handle_match(*matchdata.captures)
      end
    end
  end

  def term
    term = @search.term.sub(/\s*?(?:[aA][nN][dD])?\s*#{pattern}\s*(?:[aA][nN][dD])?\s*/, ' ')
    term.strip
  end

  def suggestion
    @suggestion ||= if @conditions
                      search = Entry.search_klass.new(:conditions => @conditions.deep_symbolize_keys.merge(:term => term))
                      search.prior_term = @prior_term if @prior_term
                      search
                    end
  end
end
