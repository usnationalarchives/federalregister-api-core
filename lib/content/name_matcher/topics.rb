module Content
  class NameMatcher
    class Topics < Content::NameMatcher
      def model
        TopicName
      end
      
      def candidates
        Topic.all
      end
      
      def assign(obj, value)
        obj.topics = [value]
        obj.save
      end
    end
  end
end