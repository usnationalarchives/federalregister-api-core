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

  describe '.fix_hyphentated_word_searches' do
    def results_for(term)
      ApplicationSearch::TermPreprocessor.fix_hypenated_word_searches(term)
    end

    it "puts hyphenated words in a phrase, removing the hypen" do
      results_for('fish-man').should ==
                  '"fish man"'
    end
  
    it "removing the hypen from hyphenated words that are inside a phrase" do
      results_for('"i told the fish-man the story"').should ==
                  '"i told the fish man the story"'
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
