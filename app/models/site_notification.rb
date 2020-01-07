class SiteNotification < ActiveRecord::Base
  scope :active, -> { where("active = true") }
end
