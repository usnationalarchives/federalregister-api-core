# == Schema Information
#
# Table name: docket_documents
#
#  id        :string(255)     primary key
#  docket_id :string(255)
#  title     :string(255)
#  metadata  :text
#

class DocketDocument < ApplicationModel
  serialize :metadata, Hash
  belongs_to :docket
end
