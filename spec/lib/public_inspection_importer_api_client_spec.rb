require 'spec_helper'

describe Content::PublicInspectionImporter::ApiClient do

  it "raises an error on parseable JSON response that returns a 200" do
    response_body = OpenStruct.new(code: 200, body: "[]", ok?: true)
    allow_any_instance_of(Content::PublicInspectionImporter::ApiClient).to receive(:get).and_return(response_body)
    importer = Content::PublicInspectionImporter::ApiClient.new
    expect{ importer.documents }.to raise_error(Content::PublicInspectionImporter::ApiClient::NotifiableResponseError)
  end

  it "raises an error if no documents are returned" do
    response_body = OpenStruct.new(code: 200, body: "", ok?: true)
    allow_any_instance_of(Content::PublicInspectionImporter::ApiClient).to receive(:get).and_return(response_body)
    allow_any_instance_of(Nokogiri::XML::Document).to receive(:xpath).and_return([])
    importer = Content::PublicInspectionImporter::ApiClient.new

    expect{ importer.documents }.to raise_error(Content::PublicInspectionImporter::ApiClient::NotifiableResponseError)
  end

end
