class Date
  def self.set_today(date, &block)
    $_mock_date = Date.parse(date)
   
    Date.class_eval do
      class <<self
        alias original_today today
      end

      def self.today
        $_mock_date
      end
    end
    
    yield
    
    Date.class_eval do
      class <<self
        alias today original_today
      end
    end
  end
end