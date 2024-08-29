require 'spec_helper'

describe EntryRegulationsDotGovAllowLateCommentImporter do
  let!(:entry) do
    Factory.create(
      :entry,
      regulations_dot_gov_document_id: "HHS_FRDOC_0001-0882",
    )
  end
  let!(:regs_dot_gov_document) do
    Factory(
      :regs_dot_gov_document,
      federal_register_document_number:          entry.document_number,
      original_federal_register_document_number: entry.document_number,
      regulations_dot_gov_document_id:           entry.regulations_dot_gov_document_id
    )
  end

  it "sets the allow late comment attributes based on the API response" do
    detailed_document = RegulationsDotGov::V4::DetailedDocument.new({
      'id'       => "HHS_FRDOC_0001-0882",
      'attributes' => {
        'allowLateComments' => true
      }
    })
    allow_any_instance_of(described_class).to receive(:detailed_document).and_return(detailed_document)

    expect_any_instance_of(Entry).to receive(:reindex!)
    expect_any_instance_of(Entry).to receive(:clear_varnish!)
    described_class.new.perform(
      entry.regulations_dot_gov_document_id,
      Time.new(2024,1,1).to_s(:iso)
    )

    expect(regs_dot_gov_document.reload).to have_attributes(
      allow_late_comments:            true,
      allow_late_comments_updated_at: be_present
    )
  end

  it "does not attempt to update the late comment attributes if the last_modified_datetime_string occurs before the last time the regs.gov document allow_late_comments_updated_at" do
    regs_dot_gov_document.update!(
      allow_late_comments_updated_at: Time.new(2025,1,1)
    )

    expect do
      # ie This call would fail if it calls #detailed_document
      described_class.new.perform(
        entry.regulations_dot_gov_document_id,
        Time.new(2024,1,1).to_s(:iso)
      )
    end.not_to raise_error
  end

end
