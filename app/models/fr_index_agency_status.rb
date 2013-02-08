# == Schema Information
#
# Table name: fr_index_agency_statuses
#
#  id                             :integer(4)      not null, primary key
#  year                           :integer(4)
#  agency_id                      :integer(4)
#  last_completed_issue           :date
#  needs_attention_count          :integer(4)
#  oldest_issue_needing_attention :date
#

class FrIndexAgencyStatus < ApplicationModel
  validates_presence_of :year, :agency_id
  validates_uniqueness_of :agency_id, :scope => :year

  def self.update_cache(agency_year)
    status = FrIndexAgencyStatus.find_or_initialize_by_year_and_agency_id(agency_year.year, agency_year.agency.id)
    status.needs_attention_count = agency_year.calculate_needs_attention_count
    status.oldest_issue_needing_attention = agency_year.calculate_oldest_issue_needing_attention
    status.save!
  end
end
