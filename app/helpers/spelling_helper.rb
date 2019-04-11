module SpellingHelper
  def spelling_checker
    checker = SpellChecker.new(:template => self)

    yield(checker)

    checker.close
  end
end
