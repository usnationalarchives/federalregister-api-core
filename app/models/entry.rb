class Entry < ActiveRecord::Base
  has_many :agency_assignments
  has_many :agencies, :through => :agency_assignments
  
  has_many :topic_assignments
  has_many :topics, :through => :topic_assignments
  
  has_many :url_references
  has_many :urls, :through => :url_references
  
  has_many :place_determinations
  has_many :places, :through => :place_determinations
  
  def month_year
    publication_date.to_formatted_s(:month_year)
  end
  
  def day
    publication_date.strftime('%d')
  end
end