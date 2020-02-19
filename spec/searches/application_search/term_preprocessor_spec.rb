require "spec_helper"

describe 'ApplicationSearch::TermPreprocessor' do
  describe '.process_term' do
    it "puts it all together" do
      ApplicationSearch::TermPreprocessor.process_term(
        'a "running back" in the end-zone is awesome"').should ==
        'a "=running =back" in the "=end =zone" is awesome '
    end
  end

  describe '.remove_extra_quote_mark' do
    def results_for(term)
      ApplicationSearch::TermPreprocessor.remove_extra_quote_mark(term)
    end

    it "doesn't change terms without quotes" do
      results_for('some text').should ==
                  'some text'
    end

    it "doesn't change terms with paired quotes" do
      results_for('boat "fishing rod" near "los angeles" ca').should ==
                  'boat "fishing rod" near "los angeles" ca'
    end

    it "removes the last quote if unpaired" do
      results_for('she said "afsasf').should ==
                  'she said  afsasf'
    end
  end

  describe ".remove_trailing_dashes" do
    def results_for(term)
      ApplicationSearch::TermPreprocessor.remove_trailing_dashes(term)
    end

    it "removes a single trailing dash" do
      results_for('CMS-CMS-9915-').should == 'CMS-CMS-9915'
    end

    it "removes multiple trailing dashes" do
      results_for('CMS-CMS-9915--').should == 'CMS-CMS-9915'
    end
  end

  describe '.remove_invalid_sequences' do
    def results_for(term)
      ApplicationSearch::TermPreprocessor.remove_invalid_sequences(term)
    end

    it "allows a slash after quotes (quorum)" do
      results_for('"a b c"/2').should ==
                  '"a b c"/2'
    end

    it "removes tildes elsewhere" do
      results_for('HIV/AIDS').should ==
                  'HIV AIDS'
    end

    it "allows a tilde after quotes (proximity)" do
      results_for('"a b c"~2').should ==
                  '"a b c"~2'
    end

    it "removes tildes elsewhere" do
      results_for('~98.6').should ==
                  ' 98.6'
    end

    it "removes @ everywhere" do
      results_for('hello@nsa.gov').should ==
                  'hello nsa.gov'
    end

    it "removes triple less than everywhere" do
      results_for('a <<< b').should ==
                  'a   b'
    end
  end

  describe '.fix_hyphentated_word_searches' do
    def results_for(term)
      ApplicationSearch::TermPreprocessor.fix_hypenated_word_searches(term)
    end
    it "does nothing to true negation searches" do
      results_for('fish -man').should ==
                  'fish -man'
      results_for('fish -"e p a"').should ==
                  'fish -"e p a"'
    end
    it "puts hyphenated words in a phrase, removing the hypen" do
      results_for('fish-man').should ==
                  '"fish man"'
    end

    it "puts multiple hyphenated words in a phrase, removing the hypen" do
      results_for('fish-man-cart hero-of-the-day').should ==
                  '"fish man cart" "hero of the day"'
    end

    it "removing the hypen from hyphenated words that are inside a phrase" do
      results_for('"i told the fish-man the story"').should ==
                  '"i told the fish man the story"'
    end

    it "removing the hypen from multiple hyphenated words that are inside a phrase" do
      results_for('"i told the fish-man-cart the funny-story"').should ==
                  '"i told the fish man cart the funny story"'
    end
  end

  describe '.use_exact_word_matching_within_phrase' do
    def results_for(term)
      ApplicationSearch::TermPreprocessor.use_exact_word_matching_within_phrase(term)
    end

    it "puts '=' symbols in front of every word in a phrase" do
      results_for('"fish man"').should ==
                  '"=fish =man"'
    end

    it "doesn't modify non-phrase searches" do
      results_for('fish man').should ==
                  'fish man'
    end

    it "doesn't modify non-phrase fragments" do
      results_for('goat "fish man" -dog').should ==
                  'goat "=fish =man" -dog'
    end

    it "handles existing '=' symbols" do
      results_for('"fish =man"').should ==
                  '"=fish =man"'
    end
  end
end
