module ApplicationSearch::TermPreprocessor
  def self.process_term(term)
    return if term.nil?
    processed_term = term.dup
    processed_term = remove_extra_quote_mark(processed_term)
    processed_term = remove_invalid_sequences(processed_term)
    processed_term = fix_hypenated_word_searches(processed_term)
    processed_term = use_exact_word_matching_within_phrase(processed_term)
    processed_term
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

  def self.fix_hypenated_word_searches(term)
    # quote hyphenated words outside phrases
    processed_term = term.gsub(/
      \b
      ((?:
        \w+                               (?#   some word characters )
        -                                 (?#   a hyphen )
      )+)
      (\w+)                               (?# some word characters )
      (?=(?:[^"]*"[^"]*")*[^"]*$)         (?# an even number of quotes afterwards )
    /x, '"\1\2"')

    # remove hyphens in identifiers inside phrases
    processed_term.gsub(/
      (\w+)                               (?# some word characters )
      -                                   (?# a hyphen )
      (?=                                 (?# looking ahead to... )
        \w+                               (?#   another word character )
        (?:[^"]*"[^"]*")*[^"]*"[^"]*$     (?#   an odd number of quotes afterwards )
      )
    /x, '\1 \2')
  end

  def self.use_exact_word_matching_within_phrase(term)
    term.gsub(/
      ([ "])                              (?# a space or an opening quote )
      (\w+)                               (?# some word characters )
      (?=(?:[^"]*"[^"]*")*[^"]*"[^"]*$)   (?# an odd number of quotes afterwards)
    /x, '\1=\2')
  end
end
