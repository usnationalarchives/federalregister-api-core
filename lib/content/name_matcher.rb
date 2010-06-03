module Content
  class NameMatcher
    def matcher
      @matcher ||= FuzzyMatcher.new(:candidates => candidates, :label_method => :name, :additional_stopwords => %w(department committee bureau) )
    end
    
    def perform
      model.unprocessed.each do |obj|
        best_match = matcher.suggest(obj.name)
        warn "suggesting '#{best_match.try(:name)}' for '#{obj.name}'"
        assign(obj, best_match) if best_match
      end
    end
  end
end