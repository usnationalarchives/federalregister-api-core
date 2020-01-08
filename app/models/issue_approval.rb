class IssueApproval < ApplicationModel
  validates_uniqueness_of :publication_date

  def cache_manually_expired?
    created_at != updated_at
  end

  def self.latest_publication_date
    IssueApproval.
      select("publication_date").
      order("publication_date DESC").
      first.
      try(:publication_date)
  end
end
