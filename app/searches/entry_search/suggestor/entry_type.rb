class EntrySearch::Suggestor::EntryType < EntrySearch::Suggestor::Base
  private
  TYPE_NAMES = {
    'rule' => 'RULE',
    'proposed rule' => 'PRORULE',
    'prorule' => 'PRORULE',
    'notice' => 'NOTICE',
    'presdoc' => 'PRESDOCU',
    'presidential document' => 'PRESDOCU',
    'president' => 'PRESDOCU',
    'presidential' => 'PRESDOCU',
    'executive document' => 'PRESDOCU',
  }

  def pattern
    /(#{TYPE_NAMES.keys.map{|n| "(?:^|[^a-zA-Z0-9=-])(#{n})\\b"}.join("|")})(?=(?:[^"]*"[^"]*")*[^"]*$)/i
  end

  def handle_match(all,*type_names)
    type_name = type_names.compact.first
    entry_type = TYPE_NAMES[type_name.to_s.downcase]
    if entry_type
      @conditions[:type] = Array(entry_type)
    end
  end
end
