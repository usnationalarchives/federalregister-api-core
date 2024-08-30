# Oftentimes the regs.gov /documents endpoint returns invalid document numbers as having changed.  We don't want to waste time trying to sync 

module InvalidDocumentNumberIdentifier

  INVALID_REGEX_PATTERNS = [
    /\A\d+\z/, # Digits-only (eg 88 or 7486)
    /^(Vol)/, 
    /^(2[1-9]|[3-8][0-9]|9[0-1])/, # Begins with a number between 21 and 91 (inclusive)
    /^[^0-9][^0-9]/ # First two characters are both not numbers (eg CDC-2024-0015)
  ]

  def invalid_document_number?(string)
    INVALID_REGEX_PATTERNS.any? { |regex| regex.match?(string) }
  end

end
