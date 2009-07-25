=begin Schema Information

 Table name: agencies

  id         :integer(4)      not null, primary key
  parent_id  :integer(4)
  name       :string(255)
  created_at :datetime
  updated_at :datetime

=end Schema Information

class Agency < ActiveRecord::Base
  has_many :agency_assignments
  has_many :entries, :through => :agency_assignments
  
  def entry_count_by_week
    entry_counts = Entry.connection.select_all("
      SELECT WEEK(entries.publication_date) AS pub_week, COUNT(entries.id) AS entry_count
      FROM entries, agencies, agency_assignments
      WHERE entries.id = agency_assignments.entry_id && agency_assignments.agency_id = agencies.id && agencies.id = #{self.id}
      GROUP BY WEEK(entries.publication_date)
    ")
    counts = []
    week = 1
    weeks_to_date = Time.now.strftime('%U').to_i
    entry_counts.each do |entry_count|
      pub_week = entry_count['pub_week'].to_i
      while week <= pub_week
        counts << (week == pub_week ? entry_count['entry_count'].to_i : 0)
        week = week + 1
      end
    end
    while week < weeks_to_date
      counts << 0
      week = week + 1
    end
    counts
  end
  
  def self.max_entry_count
    Entry.connection.select_value("
      SELECT COUNT(*) AS entry_count
      FROM entries
      JOIN agency_assignments ON agency_assignments.entry_id = entries.id
      GROUP BY agency_id, WEEK(entries.publication_date)
      ORDER BY entry_count DESC
      LIMIT 1
    ")
  end
end