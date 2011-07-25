module SpellChecker
  def self.speller
    @speller ||= Aspell.new1("lang" => "en_US", "jargon" => 'fr', "dict-dir" => File.join(Rails.root, 'data', 'dict'))
  end
  
  def self.correct(string)
    string.gsub(/[\w\']+/) do |word| 
      if word !~ /\d/ && !speller.check(word) 
        suggestions = speller.suggest(word)
        corrected_word = suggestions.find{|s| s !~ /\s|-/ } || suggestions.first
        
        if corrected_word.downcase != word.downcase
          if block_given?
            yield(corrected_word, word)
          else
            corrected_word
          end
        else
          word
        end
      else
        word
      end
    end
  end
end