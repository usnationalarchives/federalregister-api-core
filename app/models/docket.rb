# == Schema Information
#
# Table name: dockets
#
#  id                     :string(255)     primary key
#  regulation_id_number   :string(255)
#  comments_count         :integer(4)
#  docket_documents_count :integer(4)
#  title                  :string(255)
#  metadata               :text
#

class Docket < ApplicationModel
  serialize :metadata, Hash
  has_many :docket_documents

  def regulatory_plan
    if regulation_id_number.present?
      @regulatory_plan ||= RegulatoryPlan.find_by_regulation_id_number(regulation_id_number)
    end
  end
end
