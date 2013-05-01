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
end
