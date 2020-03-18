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

end
