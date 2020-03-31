module EsApplicationSearch::TermPreprocessor
  def self.process_term(term)
    return if term.nil?
    processed_term = term.dup
    processed_term = remove_extra_quote_mark(processed_term)
    processed_term = remove_invalid_sequences(processed_term)
    processed_term = replace_ampersand_with_plus(processed_term)
    processed_term = replace_exclamation_points_with_minus(processed_term)
    processed_term
  end

  def self.replace_ampersand_with_plus(term)
    term.gsub(/&(?=(?:[^"]*"[^"]*")*[^"]*$)/, "+")
  end

  def self.replace_exclamation_points_with_minus(term)
    term.gsub(/!(?=(?:\w+)(?:[^"]*"[^"]*")*[^"]*$)/, "-")
  end

  def self.remove_extra_quote_mark(term)
    if term.scan(/"/).size.even?
      term
    else
      term.sub(/"(?=[^"]*$)/, ' ')
    end
  end

  def self.remove_invalid_sequences(term)
    # replace slashes and tildes not immediately after a quote with a space
    term.
      gsub(/(?<!")(?:\/|~)/, ' ').
      gsub(/<<<|@/, ' ') # always replace these with spaces
  end
end
