class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true
  
  class << self
    public :preload_associations
    public :construct_finder_sql
  end
  
  # More performant than simply ORDER BY RAND()
  # See http://www.paperplanes.de/2008/4/24/mysql_nonos_order_by_rand.html for inspiration
  def self.random_selection(n)
    scoped(:joins => "JOIN (SELECT ID FROM #{table_name} ORDER BY RAND() LIMIT #{n.to_i}) AS random_ids ON #{table_name}.id = random_ids.id")
  end
  
  def self.limit(n)
    scoped(:limit => n)
  end
  
  def self.preload(*associations)
    results = scoped()
    Entry.preload_associations(results, associations)
    results
  end
end