=begin Schema Information

 Table name: agencies

  id                          :integer(4)      not null, primary key
  parent_id                   :integer(4)
  name                        :string(255)
  created_at                  :datetime
  updated_at                  :datetime
  slug                        :string(255)
  agency_type                 :string(255)
  short_name                  :string(255)
  description                 :text
  more_information            :text
  entries_count               :integer(4)
  entries_1_year_weekly       :text
  entries_5_years_monthly     :text
  entries_all_years_quarterly :text
  related_topics_cache        :text
  logo_file_name              :string(255)
  logo_content_type           :string(255)
  logo_file_size              :integer(4)
  logo_updated_at             :datetime
  url                         :string(255)
  active                      :boolean(1)
  cfr_citation                :text

=end Schema Information

class Agency < ApplicationModel
  module AssociationExtensions
    def excluding_parents
      agencies = self.compact
      parent_agency_ids = agencies.map(&:parent_id).compact
      agencies.reject{|a| parent_agency_ids.include?(a.id) }.uniq
    end
  end
  
  has_many :agency_assignments
  has_many :agencies_sections
  has_many :sections, :through => :agencies_sections
  
  has_many :entry_agency_assignments, :class_name => "AgencyAssignment", :conditions => "agency_assignments.assignable_type = 'Entry'"
  has_many :entries, :through => :entry_agency_assignments
  
  has_many :regulatory_plan_agency_assignments, :class_name => "AgencyAssignment", :conditions => {:assignable_type => "RegulatoryPlan"}
  has_many :regulatory_plans, :through => :regulatory_plan_agency_assignments, :source => :regulatory_plan
  
  has_many :children, :class_name => 'Agency', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Agency'
  
  # grab cabinet level agencies (departments) as these are top producing
  named_scope :featured, :conditions => ['name LIKE ?', '%Department']
  
  has_attached_file :logo,
                    :styles => { :thumb => "100", :small => "140", :medium => "245", :large => "580", :full_size => "" },
                    :processors => [:thumbnail],
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/amazon.yml",
                    :s3_alias_url => 'http://agency-logos.federalregister.gov.s3.amazonaws.com/',
                    :bucket => 'agency-logos.federalregister.gov',
                    :path => ":id/:style.:extension"
  
  before_validation :slugify
  validates_uniqueness_of :name, :slug
  validates_format_of :url, :with => /^https?:\/\//, :allow_blank => true
  serializable_column :entries_1_year_weekly, :entries_5_years_monthly, :entries_all_years_quarterly, :related_topics_cache
  
  named_scope :with_logo, :conditions => "agencies.logo_file_name IS NOT NULL"
  named_scope :with_entries, :conditions => "agencies.entries_count > 0"
  
  # consider using sphinx instead...
  def self.named_approximately(name)
    words = name.downcase.split(/[^a-z]+/) - %w(a and & in for of on s the)
    
    condition_sql = "(" + words.map{"agencies.name LIKE ?"}.join(" AND ") + ") OR (" + words.map{"agencies.short_name LIKE ?"}.join(" AND ") + ")"
    bind_params = words.map{|word|"%#{word}%"} * 2
    scoped(
      :conditions => [
        condition_sql, *bind_params
      ],
      :order => "agencies.name"
    )
  end
  
  def to_param
    slug
  end
  
  def name_and_short_name
    if short_name.present?
      "#{name} (#{short_name})"
    else
      name
    end
  end
  
  def sidebar_name
    # FIXME: remove downcase and capitalize_most_words - just fixing agency wierdness for now
    self.name.downcase.capitalize_most_words.gsub(/^Department of(?: the)? /,'')
  end
  
  def entry_counts_since(range_type)
    date = case range_type
      when 'month'
        1.month.ago
      when 'quarter'
        3.months.ago
      when 'year'
        1.year.ago
      end
    
    entries.count(:conditions => ["publication_date >= ?", date])
  end
  
  private
  
  def slugify
    self.slug = "#{name.downcase.gsub(/[^a-z0-9]+/, '-')}"
  end
  
end
