module ActiveRecord
  module RawResultset
    def self.included(base)
      base.send(:extend, ClassMethods)
    end
    
    module ClassMethods
      # User.find_as_hashes(:select => "id, last_name", :conditions => "id > 3") # => [{:id => "1", :last_name => "Davis"},
      #                                                                          #     {:id => "2", :last_name => "Bar" }]
      # User.find_as_hashes("select id, last_name from users where id > ?", 3)   # => [{:id => "1", :last_name => "Davis"},
      #                                                                          #     {:id => "2", :last_name => "Bar" }]
      def find_as_hashes(options)
        sql = hash_or_array_to_sql(options)
        connection.select_all(sql)
      end
  
      # User.find_as_arrays(:select => "id, last_name", :conditions => ["id < ?", 3]) # => [["1", "Davis"], ["2", "Bar"]]
      # User.find_as_arrays("SELECT id, last_name FROM users WHERE id < ?", 3)        # => { "1" => "Davis", "2" => "Bar"}
      def find_as_arrays(options)
        sql = hash_or_array_to_sql(options)
        connection.select_rows(sql)
      end
  
      # User.find_as_array(:select => "last_name", :conditions => ["id < ?", 3]) # => ["Davis","Bar"]
      # User.find_as_array("SELECT last_name FROM users WHERE id < ?", 3)        # => ["Davis","Bar"]
      def find_as_array(options)
        sql = hash_or_array_to_sql(options)
        connection.select_values(sql)
      end
      
      # User.find_as_hash(:select => "id, last_name")                        # => { "1" => "Davis", "2" => "Bar"}
      # User.find_as_hash("SELECT id, last_name FROM users WHERE id < ?", 3) # => { "1" => "Davis", "2" => "Bar"}
      def find_as_hash(options)
        Hash[*find_as_arrays(options).map{|row| row[0..1]}.flatten]
      end
  
      private
  
      def hash_or_array_to_sql(options)
        case options
        when Hash
          construct_finder_sql(options)
        when Array
          sanitize_sql_array(options)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::RawResultset)