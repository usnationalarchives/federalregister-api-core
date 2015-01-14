class IssueApproval < ApplicationModel
  validates_uniqueness_of :publication_date

  def cache_manually_expired?
    created_at != updated_at
  end

  def self.latest_publication_date
    with_exclusive_scope do
      IssueApproval.find(:first, :select => "publication_date", :order => "publication_date DESC").try(:publication_date)
    end
  end
end
