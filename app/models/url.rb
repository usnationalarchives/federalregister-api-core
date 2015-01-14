class Url < ApplicationModel
  has_many :url_references
  has_many :entries, :through => :url_references

  # named_scope :active,   :conditions => 'response_code = 200'
  # named_scope :inactive, :conditions => 'response_code != 200'

  #temp method
  def active
    true
  end
end
