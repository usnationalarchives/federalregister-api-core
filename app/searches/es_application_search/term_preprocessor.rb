module EsApplicationSearch::TermPreprocessor
  def self.process_term(term)
    return if term.nil?
    processed_term = term.dup
    processed_term = remove_escape_sequences(processed_term)
    processed_term = remove_extra_quote_mark(processed_term)
    processed_term = remove_invalid_sequences(processed_term)
    processed_term = wrap_words_with_leading_equals_in_quotes(processed_term)
    processed_term = fix_hyphenated_word_searches(processed_term)
    processed_term = replace_ampersand_with_plus(processed_term)
    processed_term = replace_exclamation_points_with_minus(processed_term)
    processed_term = reduce_phrase_slop_count_by_one(processed_term)
    processed_term = quote_citations_with_spaces(processed_term)
    processed_term
  end

  def self.replace_ampersand_with_plus(term)
    term.
      gsub(/
        &                           (?# ampersands)
        (?=                         (?# followed by)
          (?:[^"]*"[^"]*")*[^"]*$   (?# zero or an even number of double quotes)
        )
      /x, "+")
  end

  def self.replace_exclamation_points_with_minus(term)
    term.
      gsub(/
        !                           (?# exclamation points)
        (?=                         (?# followed by)
          (?:\w+)                   (?# a word)
          (?:[^"]*"[^"]*")*[^"]*$   (?# zero or an even number of double quotes)
        )
      /x, "-")
  end

  def self.remove_extra_quote_mark(term)
    return term if term.scan(/"/).size.even?

    term.
      sub(/
        "                           (?# double quotes)
        (?=[^"]*$)                  (?# followed by any character except a double quote until EOL)
      /x, ' ')
  end

  def self.remove_invalid_sequences(term)
    # replace slashes and tildes not immediately after a quote with a space
    term.
      gsub(/
        (?<!")                      (?# negative lookbehind for double quote)
        (?:\/|~)                    (?# replace forward slashes and tildes)
      /x, ' ').
      gsub(/
        <<<|@                       (?# always replace these with spaces)
      /x, ' ')
  end

  def self.wrap_words_with_leading_equals_in_quotes(term)
    term.gsub(/
      =[\w-]{1,}                    (?# match any equals sign followed by a word character)
    /x) do |match|
      # remove the equals sign and replace hyphens with spaces, then wrap in double quotes
      match.
        gsub("=", "").
        gsub("-", " ").
        inspect
    end
  end

  def self.reduce_phrase_slop_count_by_one(term)
    term.gsub(/
      ".*"~\d{1,}                   (?# match any quoted phrase followed by a tilde and digits)
    /x) do |match|
      match.gsub(/~(\d{1,})/) do |operator_and_count|
        # Decrement the provided count by 1 unless <= 0
        count = operator_and_count.delete("~").to_i
        "~#{count <= 0 ? 0 : count - 1}"
      end
    end
  end

  def self.remove_escape_sequences(term)
    term.gsub(/
      [\a\b\n\r\t]                  (?# match any occurrences of escape sequences other than \s)
    /x, "")
  end

  def self.fix_hyphenated_word_searches(term)
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

  def self.quote_citations_with_spaces(term)
    processed_term = term
    citation_regexes = [
      Citation::CITATION_TYPES.fetch('CFR'),
      Citation::CITATION_TYPES.fetch('FR'),
    ]

    citation_regexes.each do |regex|
      processed_term = processed_term.gsub(regex) do |match|
        # Escape existing quotes in the matched term
        escaped_match = match.gsub('"', '\"')
        "\"#{escaped_match}\""
      end
    end

    processed_term
  end

end
