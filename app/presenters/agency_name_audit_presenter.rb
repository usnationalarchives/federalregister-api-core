class AgencyNameAuditPresenter
  delegate :publication_date, :to => :issue
  attr_reader :issue, :interesting_remappings, :boring_remappings

  def initialize(date)
    @issue = Issue.find_by_publication_date!(date)

    @interesting_remappings, @boring_remappings = remappings.partition(&:interesting?)
  end

  private

  def remappings
    @remappings = @issue.
      entries.
      map{|e| e.agency_names.map{|an| [an, e]}}.
      flatten(1).
      group_by(&:first).
      map {|an, pairs| Remapping.new(an, pairs.map(&:last))}
  end

  class Remapping
    IGNORED_WORDS = %w(of the on for and office united states u s)

    attr_reader :agency_name, :entries
    def initialize(agency_name, entries)
      @agency_name = agency_name
      @entries = entries
    end

    def original_name
      agency_name.name
    end

    def remapped_name
      agency_name.agency.try(:name)
    end

    def interesting?
      return false if original_name == 'Office of the Secretary'
      words(original_name) != words(remapped_name)
    end

    private

    def words(str)
      return [] if str.nil?
      str.downcase.gsub(/\W+/, ' ').split(/ /).sort.uniq - IGNORED_WORDS
    end
  end
end
