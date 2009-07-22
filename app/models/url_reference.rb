class UrlReference < ActiveRecord::Base
  belongs_to :url
  belongs_to :entry
end