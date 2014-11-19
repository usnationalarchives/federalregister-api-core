class AgencyNameAuditPresenter
  delegate :publication_date, :to => :issue
  attr_reader :issue,
    :complex_remappings,
    :basic_remappings

  def initialize(date)
    @issue = Issue.find_by_publication_date!(date)
    @complex_remappings, @basic_remappings = remappings.partition(&:complex?)
  end

  def special_documents
    @special_documents ||= issue.
      entries.
      select {|doc| doc.document_number.match(/^X/)}
  end

  def rules_without_dates
    @rules_without_dates ||= issue.
      entries.
      select do |doc|
        doc.granule_class == "RULE" &&
        doc.effective_on.blank? &&
        !doc.document_number.match(/^C-/)
      end
  end

  private
  def remappings
    @remappings = @issue.
      entries.
      map{|e| e.agency_names.map{|an| [an, e]}}.
      flatten(1).
      group_by(&:first).
      map {|an, pairs| Remapping.new(an, pairs.map(&:last))}

    @remappings.reject{|r| r.original_name.try(:downcase) == r.remapped_name.try(:downcase)}
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

    def complex?
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
