class EntrySearch::Suggestor::Spelling < EntrySearch::Suggestor::Base
  def initialize(search)
    @search = search
    if @search.term.present?
      corrected = SpellChecker.new.correct(@search.term)
      if @search.term.downcase != corrected.downcase
        @conditions = @search.conditions.dup
        @prior_term = @search.term
        @term = corrected
      end
    end
  end
  
  def term
    @term
  end
end
