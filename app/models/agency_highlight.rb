# == Schema Information
#
# Table name: agency_highlights
#
#  id              :integer(4)      not null, primary key
#  entry_id        :integer(4)
#  agency_id       :integer(4)
#  highlight_until :date
#  published       :boolean(1)
#  section_header  :string(255)
#  title           :string(255)
#  abstract        :string(255)
#

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
