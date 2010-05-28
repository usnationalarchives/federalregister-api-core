module Content
  class NameMatcher
    class Agencies < Content::NameMatcher
      def model
        AgencyName
      end
      
      def candidates
        Agency.all
      end
      
      def assign(obj, value)
        obj.agency = value
        obj.save
      end
    end
  end
end