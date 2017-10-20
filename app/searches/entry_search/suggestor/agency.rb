class EntrySearch::Suggestor::Agency < EntrySearch::Suggestor::Base
  def initialize(search)
    @search = search
    if @search.term.present?
      check_for_match
    end
  end

  def term
    @term
  end

  private

  def check_for_match
    @term = @search.term
    agency_ids = Array(@search.conditions[:agency_ids]).flatten.map(&:to_i)

    Agency.active.find_as_arrays(:select => "id, name, short_name, display_name").each do |id, *names|
      pattern = names.reject(&:blank?).compact.map{|n| "(^|[^a-zA-Z0-9=-])" + Regexp.escape(n) + "\\b"}.join('|')

      if @term =~ /(#{pattern})(?=(?:[^"]*"[^"]*")*[^"]*$)/i && ! agency_ids.include?(id.to_i)
        agency_ids << id.to_i
        @term = @term.sub(/(?:#{pattern})(?=(?:[^"]*"[^"]*")*[^"]*$)/i, '\1')
      end
    end

    if agency_ids != Array(@search.conditions[:agency_ids]).flatten.map(&:to_i)
      @conditions = @search.conditions.dup
      @conditions[:agency_ids] = agency_ids
    end
  end

end
