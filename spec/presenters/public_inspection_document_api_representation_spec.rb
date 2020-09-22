require 'spec_helper'

describe PublicInspectionDocumentApiRepresentation do
  it "#html_url" do
    public_inspection_document = Factory(:public_inspection_document, subject_1: 'test')
    representation = PublicInspectionDocumentApiRepresentation.new(public_inspection_document)
    result = representation.value(:html_url)
    expect(result).to eq("http://www.fr2.local:8081/public_inspection_documents/2020/09/22/#{public_inspection_document.document_number}/test")
  end
end
