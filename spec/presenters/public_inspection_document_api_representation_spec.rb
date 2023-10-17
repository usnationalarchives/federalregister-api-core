require 'spec_helper'

def serializer_value(field_name, pi_doc)
  PublicInspectionDocumentSerializer.attributes_to_serialize.find{|key, attribute| key == field_name}.last.method.call(pi_doc)
end

describe PublicInspectionDocumentSerializer do
  it "#html_url" do
    public_inspection_document = Factory(:public_inspection_document, subject_1: 'test', publication_date: Date.new(2020,9,22))
    result = serializer_value(:html_url, public_inspection_document)

    expect(result).to eq("http://www.fr2.local:8081/public-inspection/#{public_inspection_document.document_number}/test")
  end

  context "#page_views" do
    let(:public_inspection_document) { Factory(:public_inspection_document, filed_at: Date.new(2020,9,22)) }

    it "returns page views " do
      allow(Settings.app.public_inspection_documents).to receive(:page_view_start_date).and_return("2020-09-21")
      result = serializer_value(:page_views, public_inspection_document)
      expect(result).to eq({count: 0, last_updated: nil})
    end

    it "returns nil when a public_inspection_documents.page_view_start_date isn't set" do
      allow(Settings.app.public_inspection_documents).to receive(:page_view_start_date).and_return(nil)
      result = serializer_value(:page_views, public_inspection_document)

      expect(result).to eq(nil)
    end
  end
  context "#agency_letters" do
    let(:pil_agency_letter) {PilAgencyLetter.new(id: 1, file_file_name: 'letter_2019-07119_USGS.pdf', title: 'Test Agency Letter', file_content_type: 'application/pdf')}
    let(:public_inspection_document) { FactoryGirl.build(:public_inspection_document, publication_date: Date.new(2099,10,15), pil_agency_letters: [pil_agency_letter]) }

    it "shows the agency letter if the current date is less than the publication date" do
      result = serializer_value(:agency_letters, public_inspection_document)

      expect(result).to eq([
        {
          title: 'letter_2019-07119_USGS.pdf',
          url: "https://public-inspection.example.com/pil_agency_letters/1/letter_2019-07119_USGS.pdf",
        }
      ])
    end
  end
end
