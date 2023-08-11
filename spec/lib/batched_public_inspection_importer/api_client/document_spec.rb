require 'spec_helper'

describe Content::PublicInspectionImporter::ApiClient::Document do

  it "can accept XML or serialized JSON as source input" do
    pi_doc_xml_node = create_sample_pi_doc_xml_node!
    xml_based_api_doc = described_class.new(double("client"), pi_doc_xml_node)

    json_representation = xml_based_api_doc.as_json
    expect(json_representation).to include({
      DocumentNumber: "2023-16252",
      EditorialNote: nil,
      Category: "RULES",
      SubjectLine: "Medicare Program:",
      Subject2: "Hospital Inpatient Prospective Payment Systems for Acute Care Hospitals and the Long Term Care Hospital Prospective Payment System and Policy Changes, etc.",
      Subject3: nil,
      FilingSection: "Special",
    }.stringify_keys)

    json_based_api_doc = described_class.new(double("client"), json_representation)

    # Test to ensure method results (particularly timezone sensitive results) are the same after being initialized via eDocs XML, serialized to JSON for the background job, and re-instantiated based on the JSON
    (
      described_class::ATTRIBUTE_CONFIGURATION.values +
      %w(agency_names filed_at update_pil_at file_until publication_date docket_numbers pdf_url pdf_url?)
    ).each do |attribute|
      expect(xml_based_api_doc.send(attribute)).to eq(json_based_api_doc.send(attribute))
    end

  end
end
