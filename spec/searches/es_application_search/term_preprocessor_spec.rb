require "spec_helper"

describe EsApplicationSearch::TermPreprocessor do
  describe '.process_term' do
    it "puts it all together" do
      pending("update others first")
      described_Class.process_term(
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
end
