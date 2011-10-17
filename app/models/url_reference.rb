# == Schema Information
#
# Table name: url_references
#
#  id         :integer(4)      not null, primary key
#  url_id     :integer(4)
#  entry_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class UrlReference < ApplicationModel
  belongs_to :url
  belongs_to :entry
end
