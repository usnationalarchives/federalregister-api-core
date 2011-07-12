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
    Agency.active.find_as_arrays(:select => "id, name, short_name, display_name").each do |id, *names|
      pattern = names.compact.map{|n| "\\b" + Regexp.escape(n) + "\\b"}.join('|')
      if @term =~ /(#{pattern})/i
        @conditions ||= @search.conditions.dup
        @conditions[:agency_ids] ||= []
        @conditions[:agency_ids] << id.to_i
        @term = @term.sub(/\s*(?:#{pattern})\s*/i, '')
      end
    end
  end
  
end