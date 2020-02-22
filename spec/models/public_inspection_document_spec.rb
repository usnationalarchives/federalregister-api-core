require 'spec_helper'

describe PublicInspectionDocument do
  describe "#to_hash" do
    it "serializes title" do
      document = described_class.new(subject_1: "one", subject_2: "two", subject_3: "three", document_number: '2011-27460')
      expect(document.to_hash[:title]).to eq "one two three"
    end

    it "serializes agency_ids" do
      document = described_class.new(document_number: '2011-27460')

      agency_a = Factory(:agency)
      agency_b = Factory(:agency)
      AgencyAssignment.create(assignable: document, agency: agency_a)
      AgencyAssignment.create(assignable: document, agency: agency_b)

      expect(document.to_hash[:agency_ids]).to eq [agency_a.id, agency_b.id]
    end
  end
end
