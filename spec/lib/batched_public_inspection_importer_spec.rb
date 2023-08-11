require 'spec_helper'
require 'sidekiq/testing'

describe Content::BatchedPublicInspectionImporter do

  it "performs an import successfully" do
    Sidekiq::Testing.inline! do
      pi_doc_xml_node = create_sample_pi_doc_xml_node!
      xml_based_api_doc = Content::PublicInspectionImporter::ApiClient::Document.new(double("client"), pi_doc_xml_node)

      # Stub 
      allow_any_instance_of(Content::PublicInspectionImporter::ApiClient).to receive(:documents).and_return([
        xml_based_api_doc
      ])
      allow_any_instance_of(Content::PublicInspectionImporter::ApiClient).to receive(:session_token).and_return('dummy_session_token')
      allow_any_instance_of(PublicInspectionDocument).to receive(:persist_document_file_path)
      allow_any_instance_of(PublicInspectionDocumentFileImporter).to receive(:download_file)
      allow_any_instance_of(PublicInspectionDocumentFileImporter).to receive(:set_num_pages)
      allow_any_instance_of(PublicInspectionDocumentFileImporter).to receive(:watermark_file_and_put_on_s3)

      begin
        temp_file = Tempfile.new
        allow_any_instance_of(PublicInspectionDocumentFileImporter).to receive(:pdf_path).and_return(temp_file.path)
        described_class.new.perform
      ensure
        temp_file.close
        temp_file.unlink
      end

      result = PublicInspectionDocument.first
      expect(result).to have_attributes(
        document_number: '2023-16252',
        granule_class: 'RULE',
        publication_date: Date.new(2023,8,28),
        special_filing: true,
        subject_1: 'Medicare Program:',
        subject_2: 'Hospital Inpatient Prospective Payment Systems for Acute Care Hospitals and the Long Term Care Hospital Prospective Payment System and Policy Changes, etc.',
        subject_3: nil,
        category: 'Rules'
      )
      expect(PublicInspectionIssue.count).to eq(1)
    end
  end

end
