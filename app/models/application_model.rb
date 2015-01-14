class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true
  include ViewHelper

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

  # Calculates the results immediately, so additional query filters cannot be appended
  def self.preload(*associations)
    results = scoped({})
    preload_associations(results, associations)
    results
  end

  # Force MySQL to join tables in provided order.
  #   Calculates the results immediately, so additional query filters cannot be appended
  def self.straight_join
    sql = construct_finder_sql(self.current_scoped_methods[:find])
    sql.sub!(/^SELECT/, 'SELECT STRAIGHT_JOIN')
    find_by_sql(sql)
  end
end
