class EntrySearch::Suggestor::Sorn < EntrySearch::Suggestor::Base

  def term
    term = @search.term
    term.strip
  end

  private

  def pattern
    /(sorn|privacy|privacy act|statement of records|statement of records notice)/i
  end

  def handle_match(all,*type_names)
    @conditions[:type] = Array('NOTICE')
    @conditions[:notice_type] = Array('sorn')
  end

end
