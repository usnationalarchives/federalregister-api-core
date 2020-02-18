class SmallEntity < ApplicationModel
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: true

  has_and_belongs_to_many :regulatory_plans

  def self.find_by_identifier!(identifier)
    find_by_name!(identifier.gsub(/-/, ' ').capitalize_words)
  end

  def identifier
    name.downcase.gsub(/ /, '-')
  end
end
