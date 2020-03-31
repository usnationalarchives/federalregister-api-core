module EsApplicationSearch::TermPreprocessor
  def self.process_term(term)
    return if term.nil?
    processed_term = term.dup
    processed_term = replace_ampersand_with_plus(processed_term)
    processed_term = replace_exclamation_points_with_minus(processed_term)
    processed_term
  end

  def self.replace_ampersand_with_plus(processed_term)
    processed_term.gsub(/&(?=(?:[^"]*"[^"]*")*[^"]*$)/, "+")
  end

  def self.replace_exclamation_points_with_minus(processed_term)
    processed_term.gsub(/!(?=(?:\w+)(?:[^"]*"[^"]*")*[^"]*$)/, "-")
  end

end
