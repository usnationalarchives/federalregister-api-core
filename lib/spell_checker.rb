class SpellChecker
  attr_reader :speller, :template

  def initialize(options={})
    @template = options[:template]
    @speller = FFI::Hunspell.dict('en_US')
  end

  def close
    speller.close
  end

  def dictionary_words
    @dictionary_words ||= DictionaryWord.find_as_array(:select => "word")
  end

  def highlight_spelling_errors(text)
    correct(text) do |original, suggestions|
      template.content_tag(:span, original, :'data-suggestions' => suggestions.to_json, :class => "spelling_error")
    end
  end

  def highlight_corrections(text)
    correct(text) do |original, suggestions|
      if suggestions.present?
        template.content_tag(:strong, suggestions.first)
      else
        original
      end
    end
  end

  def correct(string)
    string.gsub(/\w[\w\']*\w+/) do |word| 
      if word !~ /\d/ && word !~ /\A[A-Z]+\z/ && !speller.check?(word) && ! dictionary_words.include?(word.capitalize_first)
        suggestions = speller.suggest(word)

        if block_given?
          yield(word, suggestions)
        else
          suggestions.first
        end
      else
        word
      end
    end
  end
end
