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

    sql = Agency.active.select("id, slug, name, short_name, display_name").to_sql

    Agency.find_as_arrays(sql).each do |id, slug, *names|
      pattern = names.reject(&:blank?).compact.map do |name|
        '(?<=\A|[^a-zA-Z0-9=-])' +
        Regexp.escape(name) +
         '(?=\z|[^a-zA-Z0-9=-])'
      end.join('|')

      if @term =~ /(#{pattern})(?=(?:[^"]*"[^"]*")*[^"]*$)/i && ! agencies.include?(slug)
        agencies << slug
        @term = @term.sub(/(?:#{pattern})(?=(?:[^"]*"[^"]*")*[^"]*$)/i, '')
        @term = @term.delete_prefix("-")
      end
    end

    if agencies != Array(@search.conditions[:agencies]).flatten
      @conditions = @search.conditions.dup
      @conditions[:agencies] = agencies
    end
  end

end
