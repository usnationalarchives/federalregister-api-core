require 'spec_helper'

describe PublicInspectionDocumentApiRepresentation do
  it "#html_url" do
    public_inspection_document = Factory(:public_inspection_document, subject_1: 'test', publication_date: Date.new(2020,9,22))
    representation = PublicInspectionDocumentApiRepresentation.new(public_inspection_document)
    result = representation.value(:html_url)
    expect(result).to eq("http://www.fr2.local:8081/public_inspection_documents/2020/09/22/#{public_inspection_document.document_number}/test")
  end

  context "#page_views" do
    let(:public_inspection_document) { Factory(:public_inspection_document, filed_at: Date.new(2020,9,22)) }

    it "returns page views " do
      allow(SETTINGS).to receive(:[]).with("public_inspection_document_page_view_start_date").and_return(Date.parse("2020-09-21"))
      representation = PublicInspectionDocumentApiRepresentation.new(public_inspection_document)

      result = representation.value(:page_views)
      expect(result).to eq({count: 0, last_updated: nil})
    end

    it "returns nil when a public_inspection_document_page_view_start_date isn't set" do
      representation = PublicInspectionDocumentApiRepresentation.new(public_inspection_document)

      result = representation.value(:page_views)
      expect(result).to eq(nil)
    end
  end
end
