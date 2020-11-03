require 'spec_helper'

describe PublicInspectionDocumentApiRepresentation do
  it "#html_url" do
    public_inspection_document = Factory(:public_inspection_document, subject_1: 'test', publication_date: Date.new(2020,9,22))
    representation = PublicInspectionDocumentApiRepresentation.new(public_inspection_document)
    result = representation.value(:html_url)
    expect(result).to eq("http://www.fr2.local:8081/public-inspection/#{public_inspection_document.document_number}/test")
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
  context "#agency_letters" do
    let(:pil_agency_letter) {PilAgencyLetter.new(id: 1, file_file_name: 'test_file.pdf', title: 'Test Agency Letter')}
    let(:public_inspection_document) { FactoryGirl.build(:public_inspection_document, publication_date: Date.new(2099,10,15), pil_agency_letters: [pil_agency_letter]) }

    it "shows the agency letter if the current date is less than the publication date" do
      representation = PublicInspectionDocumentApiRepresentation.new(public_inspection_document)

      result = representation.value(:agency_letters)
      expect(result).to eq([
        {
          title: 'test_file.pdf',
          url: "https://public-inspection.example.org/pil_agency_letters/1/original.pdf",
        }
      ])
    end
  end
end
