class PublicInspectionIssue < ApplicationModel
  has_and_belongs_to_many :public_inspection_documents,
                          :join_table              => :public_inspection_postings,
                          :foreign_key             => :issue_id,
                          :association_foreign_key => :document_id
  named_scope :published, :conditions => "published_at IS NOT NULL"

  def self.earliest_publication_date
    published.first(:order => "publication_date").publication_date
  end

  def self.latest_publication_date
   current.publication_date
  end

  def self.current
     published.first(:order => "publication_date DESC")
  end

  def self.published_between(start_date, end_date)
    published.all(
      :conditions => ["publication_date >= ? && publication_date <= ?", start_date, end_date]
    )
  end

  def special_filing_documents
    @special_filing_documents ||= public_inspection_documents.select{|doc| doc.special_filing?}
  end

  def regular_filing_documents
    @regular_filing_documents ||= public_inspection_documents.reject{|doc| doc.special_filing?}
  end

  def special_filing_agencies
    @special_filing_agencies ||= special_filing_documents.map{|doc| doc.agencies.excluding_parents}.flatten.uniq
  end

  def regular_filing_agencies
    @regular_filing_agencies ||= regular_filing_documents.map{|doc| doc.agencies.excluding_parents}.flatten.uniq
  end

  def calculate_counts
    self.special_filing_documents_count = special_filing_documents.count
    self.special_filing_agencies_count = special_filing_agencies.count
    self.regular_filing_documents_count = regular_filing_documents.count
    self.regular_filing_agencies_count = regular_filing_agencies.count
  end
end
