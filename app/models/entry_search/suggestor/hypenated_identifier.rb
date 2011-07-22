class EntrySearch::Suggestor::HyphenatedIdentifier < EntrySearch::Suggestor::Base
  def initialize(search)
    @search = search
    if @search.term.present?
      term_without_quotes = @search.term
      term_without_quotes.scan(/
            (?:^|[^a-zA-Z\d-])            (?# beginning of string or non-identifier character)
            (?=[a-zA-Z\d]*-)              (?# lookahead to ensure identifier has a dash)
            (?=[a-zA-Z-]*\d)              (?# lookahead to ensure identifier has a number)
            (                             (?# capture the identifier)
              [a-zA-Z\d]                    (?# identifier can't start with a dash)
              [a-zA-Z\d-]+                  (?# any number of identifier characters)
              [a-zA-Z\d]                    (?# identifier can't end with a dash')
            )
            (?=([^"]*"[^"]*")*[^"]*$)     (?# confirm we're not in a double-quoted string by counting quotes after here)
            (?:[^a-zA-Z\d-]|$)            (?# not-identifier character or end of string)
          /x) do |identifier|
        identifier = identifier.first
        
        # don't suggest quoting FR document numbers; this is handled with the document
        next if Entry.count(:conditions => {:document_number => identifier}) > 0
        
        @conditions = @search.conditions.dup
        @term = @search.term.sub(/#{Regexp.escape(identifier)}/, "\"#{identifier}\"")
        return
      end
    end
  end
  
  private
  
  def term
    @term
  end
end
