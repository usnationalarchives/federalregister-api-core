class EntrySearch::Suggestor::Cfr < EntrySearch::Suggestor::Base
  private
  
  def pattern
    /(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Ss]ections?|[Ss]ec\.)?\s*(\d+)/
  end
  
  def handle_match(title, part)
    @conditions[:cfr] = {:title => title, :part => part}
  end
  
end
