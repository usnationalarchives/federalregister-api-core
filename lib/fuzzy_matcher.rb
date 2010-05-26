class FuzzyMatcher
  include Amatch
  attr_reader :candidates
  attr_accessor :label_method, :stopwords
  
  def initialize(options={})
    options.symbolize_keys!
    @label_method = options[:label_method] || :to_s
    @stopwords = options[:stopwords] || %w(and by the a an of in on to for s etc)
    @max_distance = options[:max_distance].try(:to_i) || 3
    
    self.candidates = options[:candidates] if options[:candidates]
  end
  
  def candidates=(candidates)
    @candidates = candidates
    
    @matchers = {}
    candidates.each do |candidate|
      @matchers[candidate] = Sellers.new(normalize_term(candidate.send(@label_method)))
    end
    
    candidates
  end
  
  def suggest(word)
    @candidates.map{|candidate| [@matchers[candidate].match(normalize_term(word)), candidate] }.reject{|distance, candidate| distance > @max_distance}.sort_by{|distance, candidate| distance}.first.try(:second)
  end
  
  def normalize_term(term)
    words = term.downcase.strip.split(/\s+/)
    words.reject{|w| @stopwords.include?(w) }.join(" ")
  end
end