class AgencyHighlight < ApplicationModel
  belongs_to :entry
  belongs_to :agency

  validates_presence_of :entry
  validates_presence_of :agency_id
  validates_presence_of :title
  validates_presence_of :abstract
  validates_presence_of :highlight_until

  def self.current
    scoped(:conditions => ["agency_highlights.highlight_until > ?", Time.now])
  end

  def self.published
    scoped(:conditions => {:published => true})
  end

  def self.random_choice
    published.current.scoped(:limit => 1, :order => "RAND()").first
  end
end
