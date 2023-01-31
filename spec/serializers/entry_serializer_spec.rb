require "spec_helper"

describe EntrySerializer do

  it "serializes dockets based on regs_dot_gov_documents" do
    entry = Factory(:entry)
    regs_dot_gov_docket = Factory(:regs_dot_gov_docket)
    regs_dot_gov_document_1 = Factory(:regs_dot_gov_document,
      federal_register_document_number: entry.document_number,
      docket_id: regs_dot_gov_docket.id,
      regulations_dot_gov_open_for_comment: true,
      comment_count: 999,
      comment_start_date: '2030-01-01',
      comment_end_date: '2030-12-31',
    )
    # NOTE: Ensure regs.gov docs without a docket are handled in serialization
    regs_dot_gov_document_2 = Factory(:regs_dot_gov_document,
      federal_register_document_number: entry.document_number,
      docket_id: nil,
      regulations_dot_gov_open_for_comment: false,
      comment_start_date: '2030-01-01',
      comment_end_date: '2030-12-31',
    )

    result = described_class.new(entry).to_h.fetch(:dockets)
    test = result.first
    expect(test).to include(
      id: regs_dot_gov_docket.id,
      title: regs_dot_gov_docket.title,
      agency_name: regs_dot_gov_docket.agency_id,
      supporting_documents: [],
      documents: [
        {
          allow_late_comments: regs_dot_gov_document_1.allow_late_comments,
          comment_count: 999,
          comment_end_date: regs_dot_gov_document_1.comment_end_date,
          comment_start_date: regs_dot_gov_document_1.comment_start_date,
          comment_url: "https://www.regulations.gov/commenton/#{regs_dot_gov_document_1.regulations_dot_gov_document_id}",
          id: regs_dot_gov_document_1.regulations_dot_gov_document_id,
          regulations_dot_gov_open_for_comment: true,
          updated_at: regs_dot_gov_document_1.updated_at
        }
      ],
      supporting_documents_count: nil
    )
  end

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
