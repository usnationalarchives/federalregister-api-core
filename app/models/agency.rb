=begin Schema Information

 Table name: agencies

  id         :integer(4)      not null, primary key
  parent_id  :integer(4)
  name       :string(255)
  created_at :datetime
  updated_at :datetime
  slug       :string(255)

=end Schema Information

class Agency < ActiveRecord::Base
  has_many :entries
  has_many :children, :class_name => 'Agency', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Agency'
  
  # grab cabinet level agencies (departments) as these are top producing
  named_scope :featured, :conditions => ['name LIKE ?', 'Department%']
  
  before_create :slugify
  
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
