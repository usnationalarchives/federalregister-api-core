# == Schema Information
#
# Table name: entry_page_views
#
#  id          :integer(4)      not null, primary key
#  entry_id    :integer(4)
#  created_at  :datetime
#  remote_ip   :string(255)
#  raw_referer :text(16777215)
#

class EntryPageView < ApplicationModel
  belongs_to :entry
  
  def referer=(url)
    self.raw_referer = url
  end
end
