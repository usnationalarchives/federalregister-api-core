class Url < ApplicationModel
  has_many :url_references
  has_many :entries, :through => :url_references

  # scope :active,   :conditions => 'response_code = 200'
  # scope :inactive, :conditions => 'response_code != 200'

  #temp method
  def active
    true
  end
end
