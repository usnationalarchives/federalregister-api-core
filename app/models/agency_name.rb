=begin Schema Information

 Table name: agency_names

  id              :integer(4)      not null, primary key
  name            :string(255)     not null
  agency_assigned :boolean(1)
  agency_id       :integer(4)

=end Schema Information

class AgencyName < ApplicationModel
  belongs_to :agency
  has_many :agency_name_assignments
  has_many :entries, :through => :agency_name_assignments
  
  validates_presence_of :name
  
  before_create :assign_agency_if_exact_match
  after_update :update_agency_assignments_if_agency_changed
  
  named_scope :unprocessed, :conditions => {:agency_assigned => nil}, :order => "agency_names.name"
  
  def self.find_or_create_by_name(name)
    cleaned_name = name.sub(/\W+$/, '')
    find_by_name(cleaned_name) || create(:name => cleaned_name)
  end
  
  def unprocessed?
    agency_assigned.nil?
  end
  
  
  private
  
  def assign_agency_if_exact_match
    
    agency = Agency.find_by_name(name) || Agency.find_by_name(alternative_name)
    if agency
      self.agency = agency
      self.agency_assigned = true
    end
    
    true
  end
  
  def alternative_name
    alternative_name = name.dup
    alternative_name.gsub!(/(?:U\b\.?S\b\.?|united states)/i, '') # remove U.S.

    # remove parentheticals
    alternative_name.sub!(/\(.*\)/, '')
    alternative_name.sub!(/\[.*\]/, '')
    alternative_name.sub!(/\\\\.*/, '')

    # remove semicolons on
    alternative_name.sub!(/;.*/,'')

    # remove parens on
    alternative_name.sub!(/\(.*/,'')
    
    # cleanup whitespace
    alternative_name.gsub!(/ {2,}/, ' ')
    alternative_name.gsub!(/^ /, '')
    alternative_name.gsub!(/ $/, '')
    
    alternative_name.sub!(/^(\w+) (?:of|on|for)(?: the)? (.*)/i, '\2 \1')
    
    alternative_name
  end
  
  def update_agency_assignments_if_agency_changed
    if agency_id_changed?
      entries.each do |entry|
        entry.recalculate_agencies!
      end
    end
    
    true
  end
end
