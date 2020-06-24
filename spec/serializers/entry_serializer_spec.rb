require "spec_helper"

describe EntrySerializer do

  it "serializes cfr_affected_parts correctly" do
    entry = Factory(:entry)
    EntryCfrReference.create!(
      entry_id: entry.id,
      title: 50,
      part: 625
    )

    result = described_class.new(entry).to_h.fetch(:cfr_affected_parts)

    expect(result).to eq(
      [5000625]
    )
  end

  describe "corrections" do

    it "does not mark standard documents as corrections" do
      entry = Factory(:entry)

      result = described_class.new(entry).to_h.fetch(:correction)

      expect(result).to eq(false)
    end

    it "marks executive orders with a nil presidential document number as corrections" do
      entry = Factory(:entry, presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id, presidential_document_number: nil)

      result = described_class.new(entry).to_h.fetch(:correction)

      expect(result).to eq(true)
    end

  end

end
