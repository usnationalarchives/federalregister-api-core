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
  
  before_create :slugify
  
  def to_param
    slug
  end
  
  def parent
    Agency.find_by_id(parent_id) unless parent_id.nil?
  end
  
  def entry_count_by_week(week = 0)
    if week == 0
      where_clause = "WHERE agencies.id = #{self.id}"
    else
      where_clause = "WHERE agencies.id = #{self.id} && WEEK(entries.publication_date) = #{week}"
    end
    
    entry_counts = Entry.connection.select_all("
      SELECT WEEK(entries.publication_date) AS pub_week, COUNT(entries.id) AS entry_count
      FROM agencies
      LEFT JOIN entries ON agencies.id = entries.agency_id
      #{where_clause}
      GROUP BY WEEK(entries.publication_date)
    ")
    
    counts = []
    if week == 0
      week_count = 1
      weeks_to_date = Time.now.strftime('%U').to_i
      entry_counts.each do |entry_count|
        pub_week = entry_count['pub_week'].to_i
        while week_count <= pub_week
          counts << (week_count == pub_week ? entry_count['entry_count'].to_i : 0)
          week_count = week_count + 1
        end
      end
      while week_count < weeks_to_date
        counts << 0
        week_count = week_count + 1
      end
    else
      counts = entry_counts.empty? ? 0 : entry_counts.first['entry_count'].to_i
    end
    counts
  end
  
  def self.max_entry_count
    Entry.connection.select_value("
      SELECT COUNT(*) AS entry_count
      FROM entries
      GROUP BY agency_id, WEEK(entries.publication_date)
      ORDER BY agency_id DESC
      LIMIT 1
    ")
  end
  
  def self.featured
    # grab cabinet level agencies (departments) as these are top producing
    agencies = Agency.all(:conditions => ['name LIKE ?', 'Department%'])
  end
  
  private
  
  def slugify
    self.slug = "#{name.downcase.gsub(/[^a-z0-9]+/, '-')}"
  end
  
end
