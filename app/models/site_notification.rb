class SiteNotification < ActiveRecord::Base
  scope :active, :conditions => 'active = true'
end
