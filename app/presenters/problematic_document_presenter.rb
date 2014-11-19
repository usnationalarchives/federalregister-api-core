class ProblematicDocumentPresenter
  delegate :publication_date, :to => :issue
  attr_reader :issue

  def initialize(date)
    @issue = Issue.find_by_publication_date!(date)
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
end
