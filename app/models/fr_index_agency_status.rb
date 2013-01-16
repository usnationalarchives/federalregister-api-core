# == Schema Information
#
# Table name: fr_index_agency_statuses
#
#  id                    :integer(4)      not null, primary key
#  year                  :integer(4)
#  agency_id             :integer(4)
#  last_completed_issue  :date
#  needs_attention_count :integer(4)
#

class FrIndexAgencyStatus < ApplicationModel
  validates_presence_of :year, :agency_id
  validates_uniqueness_of :agency_id, :scope => :year
end
