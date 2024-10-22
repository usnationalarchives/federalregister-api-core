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
    agencies = Array(@search.conditions[:agencies]).flatten

    agency_regexes.each do |slug, agency_identification_regex, term_substitution_regex|
      if @term =~ agency_identification_regex && ! agencies.include?(slug)
        agencies << slug
        @term = @term.sub(term_substitution_regex, '')
        @term = @term.delete_prefix("-")
      end
    end

    if agencies != Array(@search.conditions[:agencies]).flatten
      @conditions = @search.conditions.dup
      @conditions[:agencies] = agencies
    end
  end

  def agency_regexes
    # NOTE: Building up this regex at every run is slow and seems to add > 200-600ms+ to each omni-search request.
    MEMORY_STORE.fetch('agency_regexes', expires_in: 1.hour) do
      Agency.
        find_as_arrays(
          Agency.active.select("id, slug, name, short_name, display_name").to_sql
        ).
        each_with_object(Array.new) do |(id, slug, *names), array|
          pattern = names.reject(&:blank?).compact.map do |name|
            '(?<=\A|[^a-zA-Z0-9=-])' +
            Regexp.escape(name) +
            '(?=\z|[^a-zA-Z0-9=-])'
          end.join('|')

          array << [
            slug,
            /(#{pattern})(?=(?:[^"]*"[^"]*")*[^"]*$)/i,
            /(?:#{pattern})(?=(?:[^"]*"[^"]*")*[^"]*$)/i
          ]
        end
      end
  end

end
