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
    @dictionary_words ||= DictionaryWord.find_as_hash(:select => "word, 1")
  end

  def highlight_spelling_errors(text)
    spell_check(text) do |misspelled_word|
      template.content_tag(:span, misspelled_word, :'data-misspelled-word' => misspelled_word, :class => "spelling_error")
    end
  end

  def highlight_corrections(text, element=:strong, html_options={})
    correct(ERB::Util.html_escape(text)text) do |original, suggestions|
      if suggestions.present?
        template.content_tag(element, template.html_escape(suggestions.first), html_options)
      else
        original
      end
    end
  end

  def correct(string)
    spell_check(string) do |misspelled_word|
      suggestions = suggestions_for(misspelled_word)

      if block_given?
        yield(misspelled_word, suggestions)
      else
        suggestions.first || misspelled_word
      end
    end
  end

  def spell_check(string)
    string.gsub(/[a-zA-Z][a-zA-Z\']*[a-zA-Z]+/) do |word|
      if word !~ /\d/ && word !~ /\A[A-Z]+\z/ && !speller.check?(word) && ! dictionary_words[word.capitalize_first]
        yield(word)
      else
        word
      end
    end
  end

  def suggestions_for(word)
    @suggestions ||= {}
    @suggestions[word] ||= speller.suggest(word)
  end
end
