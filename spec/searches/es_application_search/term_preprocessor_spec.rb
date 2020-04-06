require "spec_helper"

describe EsApplicationSearch::TermPreprocessor do
  describe ".process_term" do
    it "puts it all together" do
      described_class.process_term(
        "a \"running back\" in the =end-zone is awesome\"").should ==
        "a \"running back\" in the \"end zone\" is awesome "
    end
  end

  describe ".replace_ampersand_with_plus" do
    def results_for(term)
      described_class.replace_ampersand_with_plus(term)
    end

    it "replaces ampersands with plus signs if no other operator conditions exist" do
      results_for("vehicular & parts & boats").should ==
                  "vehicular + parts + boats"
    end

    it "does not change terms with paired quotes" do
      results_for("\"vehicular & parts\"").should ==
                  "\"vehicular & parts\""

      results_for("\"vehicular & parts\" vehicular & \"parts\"").should ==
                  "\"vehicular & parts\" vehicular + \"parts\""
    end
  end

  describe ".replace_exclamation_points_with_minus" do
    def results_for(term)
      described_class.replace_exclamation_points_with_minus(term)
    end

    it "replaces exclamation points with minus signs if no other operator conditions exist" do
      results_for("!vehicular ! parts !boats").should ==
                  "-vehicular ! parts -boats"
    end
  end

  describe ".remove_extra_quote_mark" do
    def results_for(term)
      described_class.remove_extra_quote_mark(term)
    end

    it "does not change terms without quotes" do
      results_for("some text").should ==
                  "some text"
    end

    it "does not change terms with paired quotes" do
      results_for("boat \"fishing rod\" near \"los angeles\" ca").should ==
                  "boat \"fishing rod\" near \"los angeles\" ca"
    end

    it "removes the last quote if unpaired" do
      results_for("she said \"afsasf").should ==
                  "she said  afsasf"
    end
  end

  describe ".remove_invalid_sequences" do
    def results_for(term)
      described_class.remove_invalid_sequences(term)
    end

    it "allows a slash after quotes (quorum)" do
      results_for("\"a b c\"/2").should ==
                  "\"a b c\"/2"
    end

    it "removes tildes elsewhere" do
      results_for("HIV/AIDS").should ==
                  "HIV AIDS"
    end

    it "allows a tilde after quotes (proximity)" do
      results_for("\"a b c\"~2").should ==
                  "\"a b c\"~2"
    end

    it "removes tildes elsewhere" do
      results_for("~98.6").should ==
                  " 98.6"
    end

    it "removes @ everywhere" do
      results_for("hello@nsa.gov").should ==
                  "hello nsa.gov"
    end

    it "removes triple less than everywhere" do
      results_for("a <<< b").should ==
                  "a   b"
    end
  end

  describe ".wrap_words_with_leading_equals_in_quotes" do
    def results_for(term)
      described_class.wrap_words_with_leading_equals_in_quotes(term)
    end

    it "replaces words preceded by a '=' with quoted versions" do
      results_for("=boat fishing =rod").should ==
                  "\"boat\" fishing \"rod\""
    end

    it "wraps hyphenated words" do
      # default tokenizer is not hyphen-aware
      results_for("=fish-fish").should ==
                  "\"fish fish\""
    end

    it "does not change other occurrences of '='" do
      results_for("=\"boat\" =fishing 1 + 2 = 3").should ==
                  "=\"boat\" \"fishing\" 1 + 2 = 3"
    end
  end

  describe ".reduce_phrase_slop_count_by_one" do
    def results_for(term)
      described_class.reduce_phrase_slop_count_by_one(term)
    end

    it "decrements provided slop amounts for phrases by one" do
      results_for("\"boat fishing rod\"~3").should ==
                  "\"boat fishing rod\"~2"
    end

    it "does not change other occurrences of '~'" do
      results_for("\"boat fishing rod\" ~3").should ==
                  "\"boat fishing rod\" ~3"
    end

    it "does not change the slop number to less than zero" do
      results_for("\"boat fishing rod\"~0").should ==
                  "\"boat fishing rod\"~0"
    end

    it "does not modify the query if the operator is not followed by an integer" do
      results_for("\"boat fishing rod\"~").should ==
                  "\"boat fishing rod\"~"
    end

    it "respects quoted phrases" do
      results_for("\"fish man\"~2").should ==
                  "\"fish man\"~1"
    end

    it "handles values greater than 10" do
      results_for("(\"fish man\"~10").should ==
                  "(\"fish man\"~9"
    end

    it "handles values greater than 10" do
      results_for("(\"fish man\"~20").should ==
                  "(\"fish man\"~19"
    end
  end

  describe ".remove escape sequences" do
    def results_for(term)
      described_class.remove_escape_sequences(term)
    end

    it "removes escape sequences" do
      results_for("\n\r\b\tfish").should == "fish"
    end

    it "allows whitespace characters" do
      results_for("\sfish").should == " fish"
    end
  end
end
