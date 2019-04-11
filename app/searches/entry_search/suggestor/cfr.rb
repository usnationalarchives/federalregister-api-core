class EntrySearch::Suggestor::Cfr < EntrySearch::Suggestor::Base
  private

  def pattern
    /(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Pp]t\.?|[Ss]ections?|[Ss]ec\.)?\s*([0-9,]+)/
  end

  def handle_match(title, part)
    @conditions[:cfr] = {:title => title, :part => part.sub(/,/,'')}
  end

end
