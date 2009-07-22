class Url < ActiveRecord::Base
  has_many :url_references
  has_many :entries, :through => :url_references
end