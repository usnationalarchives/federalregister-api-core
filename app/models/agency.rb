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

=end Schema Information

class Agency < ApplicationModel
  has_many :entries
  has_many :children, :class_name => 'Agency', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Agency'
  has_many :alternative_agency_names
  
  # grab cabinet level agencies (departments) as these are top producing
  named_scope :featured, :conditions => ['name LIKE ?', 'Department%']
  
  before_create :slugify
  
  serializable_column :entries_1_year_weekly, :entries_5_years_monthly, :entries_all_years_quarterly, :related_topics_cache
  
  def to_param
    slug
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
  
  def descendant_ids
    descendant_ids = child_ids
    children.each do |child_agency|
      descendant_ids += child_agency.descendant_ids
    end
    
    descendant_ids
  end
  
  private
  
  def slugify
    self.slug = "#{name.downcase.gsub(/[^a-z0-9]+/, '-')}"
  end
  
end
