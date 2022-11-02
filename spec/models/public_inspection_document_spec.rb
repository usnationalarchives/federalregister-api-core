require 'spec_helper'

describe PublicInspectionDocument do
  describe "#to_hash" do
    it "serializes title" do
      document = described_class.new(subject_1: "one", subject_2: "two", subject_3: "three", document_number: '2011-27460')
      expect(document.to_hash[:title]).to eq "one two three"
    end

  end
end
