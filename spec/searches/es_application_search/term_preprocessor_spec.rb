require "spec_helper"

describe EsApplicationSearch::TermPreprocessor do
  describe '.process_term' do
    it "puts it all together" do
      pending("update others first")
      described_class.process_term(
        'a "running back" in the end-zone is awesome"').should ==
        'a "=running =back" in the "=end =zone" is awesome '
    end
  end

  describe '.replace_ampersand_with_plus' do
    def results_for(term)
      described_class.replace_ampersand_with_plus(term)
    end

    it "replaces ampersands with plus signs if no other operator conditions exist" do
      results_for('vehicular & parts & boats').should ==
                  'vehicular + parts + boats'
    end

    it "doesn't change terms with paired quotes" do
      results_for('"vehicular & parts"').should ==
                  '"vehicular & parts"'

      results_for('"vehicular & parts" vehicular & "parts"').should ==
                  '"vehicular & parts" vehicular + "parts"'
    end
  end

  describe '.replace_exclamation_points_with_minus' do
    def results_for(term)
      described_class.replace_exclamation_points_with_minus(term)
    end

    it "replaces exclamation points with minus signs if no other operator conditions exist" do
      results_for('!vehicular ! parts !boats').should ==
                  '-vehicular ! parts -boats'
    end
  end

  describe '.remove_extra_quote_mark' do
    def results_for(term)
      described_class.remove_extra_quote_mark(term)
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

  describe '.remove_invalid_sequences' do
    def results_for(term)
      described_class.remove_invalid_sequences(term)
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

end
