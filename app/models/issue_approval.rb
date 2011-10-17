# == Schema Information
#
# Table name: issue_approvals
#
#  id               :integer(4)      not null, primary key
#  publication_date :date
#  creator_id       :integer(4)
#  updater_id       :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

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
